import type { Metadata } from "next";
import { notFound } from "next/navigation";
import Link from "next/link";
import SectionTitle from "@/components/SectionTitle";
import TagCloud from "@/components/TagCloud";
import CtaBand from "@/components/CtaBand";
import { getNews, collectTags, tagSlug } from "@/lib/data";

export const revalidate = 60;

async function load(tag: string) {
  const all = await getNews();
  const items = all.filter((n) => n.tags.some((t) => tagSlug(t) === tag));
  const label = items[0]?.tags.find((t) => tagSlug(t) === tag) ?? tag;
  return { all, items, label };
}

export async function generateMetadata({ params }: PageProps<"/tech-news/tag/[tag]">): Promise<Metadata> {
  const { tag } = await params;
  const { items, label } = await load(tag);
  if (!items.length) return {};
  const title = `${label} Tech News & Updates for Developers`;
  const description = `Latest ${label} news for developers: ${items.length} article${items.length > 1 ? "s" : ""} explained simply.`;
  return { title, description, alternates: { canonical: `/tech-news/tag/${tag}` }, openGraph: { title, description, url: `/tech-news/tag/${tag}`, type: "website" } };
}

export default async function TagPage({ params }: PageProps<"/tech-news/tag/[tag]">) {
  const { tag } = await params;
  const { all, items, label } = await load(tag);
  if (!items.length) notFound();
  return (
    <div className="mx-auto max-w-3xl px-4 sm:px-6 pt-14 space-y-16">
      <div>
        <nav aria-label="Breadcrumb" className="font-mono text-sm text-muted mb-6">
          <Link href="/" className="hover:text-accent">Home</Link> / <Link href="/tech-news" className="hover:text-accent">Tech news</Link> / <span className="text-accent">{label}</span>
        </nav>
        <SectionTitle h1 n="topic" title={`${label} tech news`} sub={`${items.length} article${items.length > 1 ? "s" : ""} tagged ${label}.`} />
        <TagCloud basePath="/tech-news" tags={collectTags(all)} active={tag} />
        <ul className="divide-y divide-line border-y border-line">
          {items.map((n) => (
            <li key={n.id}>
              <Link href={`/tech-news/${n.slug}`} className="block py-6 group">
                <p className="font-mono text-xs text-muted">{new Date(n.created_at).toLocaleDateString("en-GB")}</p>
                <h2 className="font-display text-2xl font-semibold group-hover:text-accent transition-colors">{n.title}</h2>
                <p className="text-muted mt-1">{n.summary}</p>
              </Link>
            </li>
          ))}
        </ul>
      </div>
      <CtaBand />
    </div>
  );
}
