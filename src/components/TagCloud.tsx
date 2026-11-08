import Link from "next/link";

export default function TagCloud({ basePath, tags, active }: { basePath: string; tags: { tag: string; slug: string; count: number }[]; active?: string }) {
  if (!tags.length) return null;
  return (
    <nav aria-label="Browse by topic" className="mb-8">
      <p className="font-mono text-xs text-muted mb-2">Browse by topic</p>
      <ul className="flex flex-wrap gap-2">
        {tags.map((t) => (
          <li key={t.slug}>
            <Link
              href={`${basePath}/tag/${t.slug}`}
              className={`px-3 py-1 rounded-full text-sm border transition-colors ${t.slug === active ? "bg-accent text-accent-ink border-accent" : "border-line text-muted hover:text-fg hover:border-accent"}`}
            >
              {t.tag} <span className="opacity-60">{t.count}</span>
            </Link>
          </li>
        ))}
      </ul>
    </nav>
  );
}
