"use client";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/browser";
import { slugify } from "@/lib/slug";

type Field = { name: string; label: string; type?: "text" | "textarea" | "checkbox" | "tags" | "url" | "select"; options?: string[]; required?: boolean };
type Resource = { key: string; table: string; label: string; fields: Field[]; titleOf: (r: Row) => string; slugFrom?: string; readOnly?: boolean; order: string };
type Row = Record<string, unknown> & { id: string };

const resources: Resource[] = [
  {
    key: "news", table: "tech_news", label: "Tech news", slugFrom: "title", order: "created_at", titleOf: (r) => String(r.title),
    fields: [
      { name: "title", label: "Title", required: true },
      { name: "summary", label: "Summary", type: "textarea" },
      { name: "body", label: "Body (Markdown)", type: "textarea" },
      { name: "source_url", label: "Source URL", type: "url" },
      { name: "tags", label: "Tags (comma separated)", type: "tags" },
      { name: "published", label: "Published", type: "checkbox" },
    ],
  },
  {
    key: "interviews", table: "interview_experiences", label: "Interview experience", slugFrom: "company", order: "created_at",
    titleOf: (r) => `${r.company} — ${r.role}`,
    fields: [
      { name: "company", label: "Company", required: true },
      { name: "role", label: "Role", required: true },
      { name: "outcome", label: "Outcome", type: "select", options: ["Selected", "Rejected", "Waiting", "Unknown"] },
      { name: "rounds", label: "Rounds (e.g. OA, DSA, System design, HR)" },
      { name: "summary", label: "Summary", type: "textarea" },
      { name: "body", label: "Details (Markdown)", type: "textarea" },
      { name: "tags", label: "Tags (comma separated)", type: "tags" },
      { name: "published", label: "Published", type: "checkbox" },
    ],
  },
  {
    key: "projects", table: "projects", label: "Projects", order: "sort", titleOf: (r) => String(r.title),
    fields: [
      { name: "title", label: "Title", required: true },
      { name: "url", label: "URL", type: "url", required: true },
      { name: "category", label: "Category", type: "select", options: ["Product", "Travel & tourism", "Business", "Food & hospitality", "AI", "E-commerce & UI"] },
      { name: "kind", label: "Kind", type: "select", options: ["Product", "Client work", "Personal"] },
      { name: "description", label: "Description", type: "textarea" },
      { name: "tags", label: "Tags (comma separated)", type: "tags" },
      { name: "featured", label: "Featured on home", type: "checkbox" },
    ],
  },
  {
    key: "messages", table: "contact_messages", label: "Messages", readOnly: true, order: "created_at",
    titleOf: (r) => `${r.name} <${r.email}>`,
    fields: [{ name: "message", label: "Message", type: "textarea" }],
  },
];

const input = "w-full rounded-lg border border-line bg-surface px-3 py-2 outline-none focus:border-accent text-sm";

export default function Dashboard() {
  const router = useRouter();
  const [tab, setTab] = useState(resources[0].key);
  const res = resources.find((r) => r.key === tab)!;
  const [rows, setRows] = useState<Row[]>([]);
  const [editing, setEditing] = useState<Row | "new" | null>(null);
  const [msg, setMsg] = useState("");

  const [tick, setTick] = useState(0);
  const load = () => setTick((t) => t + 1);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      const { data, error } = await createClient().from(res.table).select("*").order(res.order, { ascending: res.order === "sort" });
      if (cancelled) return;
      if (error) setMsg(error.message);
      setRows((data as Row[]) ?? []);
    })();
    return () => { cancelled = true; };
  }, [res, tick]);

  async function remove(id: string) {
    if (!confirm("Delete this item?")) return;
    const { error } = await createClient().from(res.table).delete().eq("id", id);
    setMsg(error ? error.message : "Deleted.");
    load();
  }

  async function signOut() {
    await createClient().auth.signOut();
    router.push("/");
    router.refresh();
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h1 className="font-display text-3xl font-semibold">Dashboard</h1>
        <button onClick={signOut} className="text-sm text-muted hover:text-fg">Sign out</button>
      </div>
      <div className="flex flex-wrap gap-2 mb-6" role="tablist">
        {resources.map((r) => (
          <button key={r.key} role="tab" aria-selected={r.key === tab} onClick={() => { setTab(r.key); setEditing(null); setMsg(""); }}
            className={`px-4 py-1.5 rounded-full text-sm border ${r.key === tab ? "bg-accent text-accent-ink border-accent" : "border-line text-muted hover:text-fg"}`}>
            {r.label}
          </button>
        ))}
      </div>
      {msg && <p role="status" className="mb-4 text-sm text-muted">{msg}</p>}

      {editing ? (
        <Editor res={res} row={editing === "new" ? null : editing} onDone={(m) => { setEditing(null); if (m) setMsg(m); load(); }} />
      ) : (
        <>
          {!res.readOnly && <button onClick={() => setEditing("new")} className="mb-4 rounded-full bg-accent text-accent-ink px-5 py-2 text-sm font-medium">+ New</button>}
          <ul className="divide-y divide-line border-y border-line">
            {rows.length === 0 && <li className="py-6 text-muted text-sm">Nothing here yet.</li>}
            {rows.map((r) => (
              <li key={r.id} className="py-3 flex items-start justify-between gap-4">
                <div className="min-w-0">
                  <p className="font-medium truncate">{res.titleOf(r)}</p>
                  <p className="text-xs text-muted font-mono">
                    {r.published === false ? "draft · " : ""}{r.created_at ? new Date(String(r.created_at)).toLocaleString("en-GB") : ""}
                  </p>
                  {res.readOnly && <p className="text-sm text-muted mt-1 whitespace-pre-wrap">{String(r.message)}</p>}
                </div>
                <div className="flex gap-3 text-sm shrink-0">
                  {!res.readOnly && <button onClick={() => setEditing(r)} className="text-accent">Edit</button>}
                  <button onClick={() => remove(r.id)} className="text-red-400">Delete</button>
                </div>
              </li>
            ))}
          </ul>
        </>
      )}
    </div>
  );
}

function Editor({ res, row, onDone }: { res: Resource; row: Row | null; onDone: (m?: string) => void }) {
  const [vals, setVals] = useState<Record<string, unknown>>(() => {
    const v: Record<string, unknown> = {};
    for (const f of res.fields) {
      const cur = row?.[f.name];
      v[f.name] = f.type === "tags" ? ((cur as string[]) ?? []).join(", ") : f.type === "checkbox" ? Boolean(cur) : (cur ?? (f.type === "select" ? f.options?.[0] : ""));
    }
    return v;
  });
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState("");

  async function save(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    setErr("");
    const payload: Record<string, unknown> = {};
    for (const f of res.fields) {
      const v = vals[f.name];
      payload[f.name] = f.type === "tags" ? String(v).split(",").map((s) => s.trim()).filter(Boolean) : f.name === "image" || f.name === "source_url" ? (String(v) || null) : v;
    }
    if (res.slugFrom && !row) payload.slug = `${slugify(String(vals[res.slugFrom]))}-${Date.now().toString(36).slice(-4)}`;
    if (res.table !== "projects" && res.table !== "contact_messages") payload.updated_at = new Date().toISOString();
    const sb = createClient();
    const { error } = row ? await sb.from(res.table).update(payload).eq("id", row.id) : await sb.from(res.table).insert(payload);
    setBusy(false);
    if (error) return setErr(error.message);
    onDone("Saved.");
  }

  return (
    <form onSubmit={save} className="space-y-4 max-w-2xl">
      {res.fields.map((f) => (
        <label key={f.name} className="block text-sm">
          {f.type !== "checkbox" && <span className="block mb-1 text-muted">{f.label}</span>}
          {f.type === "textarea" ? (
            <textarea className={input} rows={f.name === "body" ? 14 : 3} value={String(vals[f.name])} onChange={(e) => setVals({ ...vals, [f.name]: e.target.value })} />
          ) : f.type === "checkbox" ? (
            <span className="flex items-center gap-2"><input type="checkbox" checked={Boolean(vals[f.name])} onChange={(e) => setVals({ ...vals, [f.name]: e.target.checked })} />{f.label}</span>
          ) : f.type === "select" ? (
            <select className={input} value={String(vals[f.name])} onChange={(e) => setVals({ ...vals, [f.name]: e.target.value })}>
              {f.options!.map((o) => <option key={o}>{o}</option>)}
            </select>
          ) : (
            <input className={input} type={f.type === "url" ? "url" : "text"} required={f.required} value={String(vals[f.name])} onChange={(e) => setVals({ ...vals, [f.name]: e.target.value })} />
          )}
        </label>
      ))}
      {err && <p role="alert" className="text-red-400 text-sm">{err}</p>}
      <div className="flex gap-3">
        <button disabled={busy} className="rounded-full bg-accent text-accent-ink px-5 py-2 text-sm font-medium disabled:opacity-60">{busy ? "Saving…" : "Save"}</button>
        <button type="button" onClick={() => onDone()} className="rounded-full border border-line px-5 py-2 text-sm">Cancel</button>
      </div>
    </form>
  );
}
