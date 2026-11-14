import type { Metadata } from "next";
import Link from "next/link";
import SectionTitle from "@/components/SectionTitle";
import CtaBand from "@/components/CtaBand";
import JsonLd from "@/components/JsonLd";
import { getLearnArticles } from "@/lib/data";
import { learnCategories, learnCategoryByLabel } from "@/lib/content";
import { abs } from "@/lib/site";

const DESC = "Learn software engineering: clear, practical guides on system design, frontend, backend, DSA, DevOps & cloud, databases and AI/ML — written for developers.";
export const metadata: Metadata = {
  title: "Learn Software Engineering: System Design, Frontend, Backend & More",
  description: DESC,
  alternates: { canonical: "/learn" },
  openGraph: { title: "Learn Software Engineering", description: DESC, url: "/learn", type: "website" },
};
export const revalidate = 60;

export default async function LearnPage() {
  const articles = await getLearnArticles();
  const byCategory = learnCategories.map((c) => ({
    ...c,
    items: articles.filter((a) => a.category === c.label),
  }));

  return (
    <div className="mx-auto max-w-5xl px-4 sm:px-6 pt-14 space-y-16">
      <JsonLd
        data={{
          "@context": "https://schema.org",
          "@type": "CollectionPage",
          name: "Learn Software Engineering",
          url: abs("/learn"),
          description: DESC,
          hasPart: articles.map((a) => ({
            "@type": "LearningResource",
            name: a.title,
            url: abs(`/learn/${learnCategoryByLabel(a.category)?.slug ?? "system-design"}/${a.slug}`),
            datePublished: a.created_at,
          })),
        }}
      />
      <div>
        <SectionTitle h1 n="learn" title="Learn software engineering" sub="Practical, no-fluff guides on the topics that actually come up at work and in interviews — from system design to AI." />

        {!articles.length ? (
          <p className="text-muted border border-dashed border-line rounded-2xl p-8">
            The first guides are coming soon. Meanwhile, read real{" "}
            <Link href="/interview-experience" className="text-accent underline">interview experiences</Link> or the latest{" "}
            <Link href="/tech-news" className="text-accent underline">tech news</Link>.
          </p>
        ) : (
          <div className="grid gap-6 sm:grid-cols-2">
            {byCategory.map((c) => (
              <section key={c.slug} className="rounded-2xl border border-line bg-surface p-6 flex flex-col">
                <div className="flex items-baseline justify-between gap-3">
                  <h2 className="font-display text-xl font-semibold">
                    <Link href={`/learn/${c.slug}`} className="hover:text-accent transition-colors">{c.label}</Link>
                  </h2>
                  <span className="font-mono text-xs text-muted shrink-0">{c.items.length} article{c.items.length === 1 ? "" : "s"}</span>
                </div>
                <p className="text-muted text-sm mt-1">{c.blurb}</p>
                <ul className="mt-4 space-y-2 flex-1">
                  {c.items.slice(0, 5).map((a) => (
                    <li key={a.id}>
                      <Link href={`/learn/${c.slug}/${a.slug}`} className="text-sm text-fg/90 hover:text-accent transition-colors">
                        {a.title}
                      </Link>
                    </li>
                  ))}
                  {!c.items.length && <li className="text-sm text-muted">Coming soon.</li>}
                </ul>
                {c.items.length > 0 && (
                  <Link href={`/learn/${c.slug}`} className="mt-4 font-mono text-xs text-accent">View all →</Link>
                )}
              </section>
            ))}
          </div>
        )}
      </div>
      <CtaBand />
    </div>
  );
}
