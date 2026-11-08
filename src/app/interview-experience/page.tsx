import type { Metadata } from "next";
import Link from "next/link";
import SectionTitle from "@/components/SectionTitle";
import CtaBand from "@/components/CtaBand";
import JsonLd from "@/components/JsonLd";
import TagCloud from "@/components/TagCloud";
import { getInterviews, collectTags } from "@/lib/data";
import { abs } from "@/lib/site";

const DESC = "Real software engineer interview experiences: rounds, coding and system design questions asked, outcomes and preparation tips from candidates.";
export const metadata: Metadata = {
  title: "Software Interview Experiences: Rounds, Questions & Tips",
  description: DESC,
  alternates: { canonical: "/interview-experience" },
  openGraph: { title: "Software Interview Experiences", description: DESC, url: "/interview-experience", type: "website" },
};
export const revalidate = 60;

export default async function InterviewsPage() {
  const list = await getInterviews();
  return (
    <div className="mx-auto max-w-3xl px-4 sm:px-6 pt-14 space-y-16">
      <JsonLd
        data={{
          "@context": "https://schema.org",
          "@type": "CollectionPage",
          name: "Software Interview Experiences",
          url: abs("/interview-experience"),
          description: DESC,
          hasPart: list.map((i) => ({ "@type": "Article", headline: `${i.company} ${i.role} interview experience`, url: abs(`/interview-experience/${i.slug}`), datePublished: i.created_at })),
        }}
      />
      <div>
        <SectionTitle h1 n="interview-experience" title="Software interview experiences" sub="Real interview rounds, questions asked, outcomes and what to prepare, shared by developers who've been through them." />
        <TagCloud basePath="/interview-experience" tags={collectTags(list)} />
        {!list.length ? (
          <p className="text-muted border border-dashed border-line rounded-2xl p-8">
            The first interview experiences are coming soon. Meanwhile, catch up on <Link href="/tech-news" className="text-accent underline">tech news for developers</Link>.
          </p>
        ) : (
          <ul className="grid gap-4">
            {list.map((i) => (
              <li key={i.id}>
                <Link href={`/interview-experience/${i.slug}`} className="block rounded-2xl border border-line bg-surface p-6 hover:border-accent transition-colors">
                  <div className="flex justify-between gap-3 font-mono text-xs text-muted">
                    <span>{new Date(i.created_at).toLocaleDateString("en-GB")}</span>
                    <span className="text-accent">{i.outcome}</span>
                  </div>
                  <h2 className="font-display text-2xl font-semibold mt-1">{i.company} <span className="text-muted font-normal">· {i.role}</span></h2>
                  <p className="text-muted mt-1">{i.summary}</p>
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
