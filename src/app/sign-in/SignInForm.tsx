"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { createClient, supabaseConfigured } from "@/lib/supabase/browser";

const field = "w-full rounded-xl border border-line bg-surface px-4 py-3 outline-none focus:border-accent mt-1";

export default function SignInForm() {
  const router = useRouter();
  const [err, setErr] = useState("");
  const [busy, setBusy] = useState(false);

  async function onSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setErr("");
    if (!supabaseConfigured()) return setErr("Supabase isn't configured yet.");
    const f = new FormData(e.currentTarget);
    setBusy(true);
    const { error } = await createClient().auth.signInWithPassword({
      email: String(f.get("email")),
      password: String(f.get("password")),
    });
    setBusy(false);
    if (error) return setErr("Invalid email or password.");
    router.push("/admin");
    router.refresh();
  }

  return (
    <form onSubmit={onSubmit} className="space-y-4">
      <label className="block text-sm">Email<input name="email" type="email" required autoComplete="username" className={field} /></label>
      <label className="block text-sm">Password<input name="password" type="password" required autoComplete="current-password" className={field} /></label>
      <button disabled={busy} className="rounded-full bg-accent text-accent-ink px-6 py-3 font-medium disabled:opacity-60">{busy ? "Signing in…" : "Sign in"}</button>
      {err && <p role="alert" className="text-red-400 text-sm">{err}</p>}
    </form>
  );
}
