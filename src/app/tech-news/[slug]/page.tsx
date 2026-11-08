import type { Metadata } from "next";
import { notFound } from "next/navigation";
import Link from "next/link";
import Markdown from "@/components/Markdown";
import CtaBand from "@/components/CtaBand";
import JsonLd from "@/components/JsonLd";
import { getNewsBySlug, tagSlug } from "@/lib/data";
import { abs, SITE_NAME } from "@/lib/site";

export const revalidate = 60;

export async function generateMetadata({ params }: PageProps<"/tech-news/[slug]">): Promise<Metadata> {
  const { slug } = await params;
  const n = await getNewsBySlug(slug);
  if (!n) return {};
  const path = `/tech-news/${n.slug}`;
  return {
    title: n.title,
    description: n.summary || undefined,
    keywords: n.tags,
    alternates: { canonical: path },
    openGraph: { type: "article", title: n.title, description: n.summary || undefined, url: path, publishedTime: n.created_at, tags: n.tags },
    twitter: { card: "summary_large_image", title: n.title, description: n.summary || undefined },
  };
}

export default async function NewsPage({ params }: PageProps<"/tech-news/[slug]">) {
  const { slug } = await params;
  const n = await getNewsBySlug(slug);
  if (!n) notFound();
  return (
    <article className="mx-auto max-w-3xl px-4 sm:px-6 pt-14">
      <JsonLd
        data={{
          "@context": "https://schema.org",
          "@type": "NewsArticle",
          headline: n.title,
          description: n.summary,
          datePublished: n.created_at,
          dateModified: n.created_at,
          keywords: n.tags.join(", "),
          mainEntityOfPage: abs(`/tech-news/${n.slug}`),
          author: { "@type": "Person", name: SITE_NAME, url: abs("/about") },
          publisher: { "@type": "Person", name: SITE_NAME },
        }}
      />
      <nav aria-label="Breadcrumb" className="font-mono text-sm text-muted">
        <Link href="/" className="hover:text-accent">Home</Link> / <Link href="/tech-news" className="text-accent">Tech news</Link>
      </nav>
      <p className="font-mono text-xs text-muted mt-6"><time dateTime={n.created_at}>{new Date(n.created_at).toLocaleDateString("en-GB")}</time></p>
      <h1 className="font-display text-4xl font-semibold tracking-tight mt-1">{n.title}</h1>
      <p className="text-lg text-muted mt-3">{n.summary}</p>
      {n.tags.length > 0 && (
        <ul className="flex flex-wrap gap-2 mt-6" aria-label="Topics">
          {n.tags.map((t) => (
            <li key={t}><Link href={`/tech-news/tag/${tagSlug(t)}`} className="text-xs font-mono px-2.5 py-1 rounded-md bg-surface-2 text-muted hover:text-accent">{t}</Link></li>
          ))}
        </ul>
      )}
      <div className="mt-8"><Markdown>{n.body}</Markdown></div>
      {n.source_url && <a href={n.source_url} target="_blank" rel="noopener noreferrer nofollow" className="inline-block mt-8 font-mono text-sm text-accent">source ↗</a>}
      <div className="mt-16"><CtaBand /></div>
    </article>
  );
}
