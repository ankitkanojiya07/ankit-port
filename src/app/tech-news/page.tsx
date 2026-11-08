import type { Metadata } from "next";
import Link from "next/link";
import SectionTitle from "@/components/SectionTitle";
import CtaBand from "@/components/CtaBand";
import JsonLd from "@/components/JsonLd";
import TagCloud from "@/components/TagCloud";
import { getNews, collectTags } from "@/lib/data";
import { abs } from "@/lib/site";

const DESC = "Latest tech news for developers: software engineering, AI, cloud and backend updates explained simply, with notes on what they mean for your work.";
export const metadata: Metadata = {
  title: "Tech News for Developers: AI, Cloud & Software Updates",
  description: DESC,
  alternates: { canonical: "/tech-news" },
  openGraph: { title: "Tech News for Developers", description: DESC, url: "/tech-news", type: "website" },
};
export const revalidate = 60;

export default async function TechPage() {
  const news = await getNews();
  return (
    <div className="mx-auto max-w-3xl px-4 sm:px-6 pt-14 space-y-16">
      <JsonLd
        data={{
          "@context": "https://schema.org",
          "@type": "CollectionPage",
          name: "Tech News for Developers",
          url: abs("/tech-news"),
          description: DESC,
          hasPart: news.map((n) => ({ "@type": "Article", headline: n.title, url: abs(`/tech-news/${n.slug}`), datePublished: n.created_at })),
        }}
      />
      <div>
        <SectionTitle h1 n="tech-news" title="Tech news for developers" sub="Software engineering, AI, cloud and backend updates, explained simply, with what they mean for your work and career." />
        <TagCloud basePath="/tech-news" tags={collectTags(news)} />
        {!news.length ? (
          <p className="text-muted border border-dashed border-line rounded-2xl p-8">
            The first tech news posts are coming soon. Meanwhile, read real <Link href="/interview-experience" className="text-accent underline">software interview experiences</Link>.
          </p>
        ) : (
          <ul className="divide-y divide-line border-y border-line">
            {news.map((n) => (
              <li key={n.id}>
                <Link href={`/tech-news/${n.slug}`} className="block py-6 group">
                  <p className="font-mono text-xs text-muted">{new Date(n.created_at).toLocaleDateString("en-GB")}</p>
                  <h2 className="font-display text-2xl font-semibold group-hover:text-accent transition-colors">{n.title}</h2>
                  <p className="text-muted mt-1">{n.summary}</p>
                  <div className="flex gap-1.5 mt-2">{n.tags.map((t) => <span key={t} className="text-xs font-mono px-2 py-0.5 rounded-md bg-surface-2 text-muted">{t}</span>)}</div>
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
