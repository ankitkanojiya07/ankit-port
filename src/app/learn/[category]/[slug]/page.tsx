import type { Metadata } from "next";
import { notFound } from "next/navigation";
import Link from "next/link";
import Markdown from "@/components/Markdown";
import CtaBand from "@/components/CtaBand";
import JsonLd from "@/components/JsonLd";
import { getLearnBySlug, getLearnByCategory } from "@/lib/data";
import { learnCategoryBySlug, learnCategoryByLabel } from "@/lib/content";
import { abs, SITE_NAME } from "@/lib/site";

export const revalidate = 60;

export async function generateMetadata({ params }: PageProps<"/learn/[category]/[slug]">): Promise<Metadata> {
  const { slug } = await params;
  const a = await getLearnBySlug(slug);
  if (!a) return {};
  const cat = learnCategoryByLabel(a.category);
  const path = `/learn/${cat?.slug ?? "system-design"}/${a.slug}`;
  return {
    title: a.title,
    description: a.summary || undefined,
    keywords: a.tags,
    alternates: { canonical: path },
    openGraph: { type: "article", title: a.title, description: a.summary || undefined, url: path, publishedTime: a.created_at, tags: a.tags },
    twitter: { card: "summary_large_image", title: a.title, description: a.summary || undefined },
  };
}

export default async function LearnArticlePage({ params }: PageProps<"/learn/[category]/[slug]">) {
  const { category, slug } = await params;
  const cat = learnCategoryBySlug(category);
  if (!cat) notFound();
  const a = await getLearnBySlug(slug);
  if (!a || a.category !== cat.label) notFound();

  const related = (await getLearnByCategory(cat.label)).filter((r) => r.slug !== a.slug).slice(0, 4);

  return (
    <article className="mx-auto max-w-3xl px-4 sm:px-6 pt-14">
      <JsonLd
        data={{
          "@context": "https://schema.org",
          "@type": "TechArticle",
          headline: a.title,
          description: a.summary,
          datePublished: a.created_at,
          dateModified: a.created_at,
          keywords: a.tags.join(", "),
          articleSection: a.category,
          proficiencyLevel: a.level,
          mainEntityOfPage: abs(`/learn/${cat.slug}/${a.slug}`),
          author: { "@type": "Person", name: SITE_NAME, url: abs("/about") },
          publisher: { "@type": "Person", name: SITE_NAME },
        }}
      />
      <nav aria-label="Breadcrumb" className="font-mono text-sm text-muted">
        <Link href="/" className="hover:text-accent">Home</Link> / <Link href="/learn" className="hover:text-accent">Learn</Link> / <Link href={`/learn/${cat.slug}`} className="text-accent">{cat.label}</Link>
      </nav>
      <p className="font-mono text-xs text-muted mt-6">{a.level} · {cat.label}</p>
      <h1 className="font-display text-4xl font-semibold tracking-tight mt-1">{a.title}</h1>
      <p className="text-lg text-muted mt-3">{a.summary}</p>
      {a.tags.length > 0 && (
        <ul className="flex flex-wrap gap-2 mt-6" aria-label="Topics">
          {a.tags.map((t) => (
            <li key={t}><span className="text-xs font-mono px-2.5 py-1 rounded-md bg-surface-2 text-muted">{t}</span></li>
          ))}
        </ul>
      )}
      <div className="mt-8"><Markdown>{a.body}</Markdown></div>

      {related.length > 0 && (
        <aside className="mt-16 border-t border-line pt-8">
          <p className="font-mono text-xs text-accent mb-3">More in {cat.label}</p>
          <ul className="space-y-2">
            {related.map((r) => (
              <li key={r.id}>
                <Link href={`/learn/${cat.slug}/${r.slug}`} className="text-fg/90 hover:text-accent transition-colors">{r.title}</Link>
              </li>
            ))}
          </ul>
        </aside>
      )}

      <div className="mt-16"><CtaBand /></div>
    </article>
  );
}
