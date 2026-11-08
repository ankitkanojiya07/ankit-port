import type { Metadata } from "next";
import { notFound } from "next/navigation";
import Link from "next/link";
import Markdown from "@/components/Markdown";
import CtaBand from "@/components/CtaBand";
import JsonLd from "@/components/JsonLd";
import { getInterviewBySlug, tagSlug } from "@/lib/data";
import { abs, SITE_NAME } from "@/lib/site";

export const revalidate = 60;

export async function generateMetadata({ params }: PageProps<"/interview-experience/[slug]">): Promise<Metadata> {
  const { slug } = await params;
  const i = await getInterviewBySlug(slug);
  if (!i) return {};
  const title = `${i.company} ${i.role} Interview Experience`;
  const path = `/interview-experience/${i.slug}`;
  const description = i.summary || `${i.company} ${i.role} interview experience: rounds, questions asked and tips.`;
  return {
    title,
    description,
    keywords: [`${i.company} interview`, `${i.company} ${i.role}`, "interview experience", ...i.tags],
    alternates: { canonical: path },
    openGraph: { type: "article", title, description, url: path, publishedTime: i.created_at, tags: i.tags },
    twitter: { card: "summary_large_image", title, description },
  };
}

export default async function InterviewPage({ params }: PageProps<"/interview-experience/[slug]">) {
  const { slug } = await params;
  const i = await getInterviewBySlug(slug);
  if (!i) notFound();
  return (
    <article className="mx-auto max-w-3xl px-4 sm:px-6 pt-14">
      <JsonLd
        data={{
          "@context": "https://schema.org",
          "@type": "Article",
          headline: `${i.company} ${i.role} Interview Experience`,
          description: i.summary,
          datePublished: i.created_at,
          dateModified: i.created_at,
          keywords: [`${i.company} interview`, ...i.tags].join(", "),
          mainEntityOfPage: abs(`/interview-experience/${i.slug}`),
          author: { "@type": "Person", name: SITE_NAME, url: abs("/about") },
          publisher: { "@type": "Person", name: SITE_NAME },
        }}
      />
      <nav aria-label="Breadcrumb" className="font-mono text-sm text-muted">
        <Link href="/" className="hover:text-accent">Home</Link> / <Link href="/interview-experience" className="text-accent">Interview experience</Link>
      </nav>
      <p className="font-mono text-xs text-muted mt-6"><time dateTime={i.created_at}>{new Date(i.created_at).toLocaleDateString("en-GB")}</time> · {i.outcome}</p>
      <h1 className="font-display text-4xl font-semibold tracking-tight mt-1">{i.company} {i.role} Interview Experience</h1>
      {i.rounds && <p className="mt-3 font-mono text-sm text-muted">Rounds: {i.rounds}</p>}
      <p className="text-lg text-muted mt-3">{i.summary}</p>
      {i.tags.length > 0 && (
        <ul className="flex flex-wrap gap-2 mt-6" aria-label="Topics">
          {i.tags.map((t) => (
            <li key={t}><Link href={`/interview-experience/tag/${tagSlug(t)}`} className="text-xs font-mono px-2.5 py-1 rounded-md bg-surface-2 text-muted hover:text-accent">{t}</Link></li>
          ))}
        </ul>
      )}
      <div className="mt-8"><Markdown>{i.body}</Markdown></div>
      <div className="mt-16"><CtaBand title="Preparing, or building something?" body="Book a call for interview guidance, or to talk about the software, app or cloud project you need built." /></div>
    </article>
  );
}
