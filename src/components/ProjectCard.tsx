import type { Project } from "@/lib/content";

export default function ProjectCard({ p, index }: { p: Project; index?: number }) {
  return (
    <a
      href={p.url}
      target="_blank"
      rel="noopener noreferrer"
      className="group block h-full rounded-2xl border border-line bg-surface overflow-hidden hover:border-accent transition-colors"
    >
      <div className="p-6">
        <div className="flex items-center justify-between gap-3 mb-2">
          <span className="font-mono text-xs text-muted">
            {index !== undefined ? String(index + 1).padStart(2, "0") + " · " : ""}
            {p.kind}
          </span>
          <span className="font-mono text-xs text-accent opacity-0 group-hover:opacity-100 transition-opacity">visit ↗</span>
        </div>
        <h3 className="font-display text-xl font-semibold">{p.title}</h3>
        <p className="text-sm text-muted mt-1.5 leading-relaxed">{p.description}</p>
        <div className="flex flex-wrap gap-1.5 mt-3">
          {p.tags.map((t) => (
            <span key={t} className="text-xs font-mono px-2 py-0.5 rounded-md bg-surface-2 text-muted">{t}</span>
          ))}
        </div>
      </div>
    </a>
  );
}
