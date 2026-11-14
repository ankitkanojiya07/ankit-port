import type { Metadata } from "next";
import { notFound } from "next/navigation";
import Link from "next/link";
import SectionTitle from "@/components/SectionTitle";
import CtaBand from "@/components/CtaBand";
import JsonLd from "@/components/JsonLd";
import { getLearnByCategory } from "@/lib/data";
import { learnCategories, learnCategoryBySlug } from "@/lib/content";
import { abs } from "@/lib/site";

export const revalidate = 60;

export async function generateMetadata({ params }: PageProps<"/learn/[category]">): Promise<Metadata> {
  const { category } = await params;
  const cat = learnCategoryBySlug(category);
  if (!cat) return {};
  const title = `${cat.label} — Learn Software Engineering`;
  const description = `${cat.label} guides for developers: ${cat.blurb}`;
  return { title, description, alternates: { canonical: `/learn/${cat.slug}` }, openGraph: { title, description, url: `/learn/${cat.slug}`, type: "website" } };
}

export default async function LearnCategoryPage({ params }: PageProps<"/learn/[category]">) {
  const { category } = await params;
  const cat = learnCategoryBySlug(category);
  if (!cat) notFound();
  const items = await getLearnByCategory(cat.label);

  return (
    <div className="mx-auto max-w-3xl px-4 sm:px-6 pt-14 space-y-16">
      <JsonLd
        data={{
          "@context": "https://schema.org",
          "@type": "CollectionPage",
          name: `${cat.label} — Learn`,
          url: abs(`/learn/${cat.slug}`),
          description: cat.blurb,
          hasPart: items.map((a) => ({ "@type": "LearningResource", name: a.title, url: abs(`/learn/${cat.slug}/${a.slug}`), datePublished: a.created_at })),
        }}
      />
      <div>
        <nav aria-label="Breadcrumb" className="font-mono text-sm text-muted mb-6">
          <Link href="/" className="hover:text-accent">Home</Link> / <Link href="/learn" className="hover:text-accent">Learn</Link> / <span className="text-accent">{cat.label}</span>
        </nav>
        <SectionTitle h1 n={`learn/${cat.slug}`} title={cat.label} sub={cat.blurb} />

        <nav aria-label="Learn categories" className="mb-8">
          <ul className="flex flex-wrap gap-2">
            {learnCategories.map((c) => (
              <li key={c.slug}>
                <Link
                  href={`/learn/${c.slug}`}
                  className={`px-3 py-1 rounded-full text-sm border transition-colors ${c.slug === cat.slug ? "bg-accent text-accent-ink border-accent" : "border-line text-muted hover:text-fg hover:border-accent"}`}
                >
                  {c.label}
                </Link>
              </li>
            ))}
          </ul>
        </nav>

        {!items.length ? (
          <p className="text-muted border border-dashed border-line rounded-2xl p-8">Guides for {cat.label} are coming soon.</p>
        ) : (
          <ul className="divide-y divide-line border-y border-line">
            {items.map((a) => (
              <li key={a.id}>
                <Link href={`/learn/${cat.slug}/${a.slug}`} className="block py-6 group">
                  <p className="font-mono text-xs text-muted">{a.level}</p>
                  <h2 className="font-display text-2xl font-semibold group-hover:text-accent transition-colors">{a.title}</h2>
                  <p className="text-muted mt-1">{a.summary}</p>
                  <div className="flex flex-wrap gap-1.5 mt-2">{a.tags.map((t) => <span key={t} className="text-xs font-mono px-2 py-0.5 rounded-md bg-surface-2 text-muted">{t}</span>)}</div>
                </Link>
              </li>
            ))}
          </ul>
        )}
      </div>
      <CtaBand />
    </div>
  );
}
