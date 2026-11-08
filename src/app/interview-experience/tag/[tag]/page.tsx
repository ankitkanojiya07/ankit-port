import type { Metadata } from "next";
import { notFound } from "next/navigation";
import Link from "next/link";
import SectionTitle from "@/components/SectionTitle";
import TagCloud from "@/components/TagCloud";
import CtaBand from "@/components/CtaBand";
import { getInterviews, collectTags, tagSlug } from "@/lib/data";

export const revalidate = 60;

async function load(tag: string) {
  const all = await getInterviews();
  const items = all.filter((n) => n.tags.some((t) => tagSlug(t) === tag));
  const label = items[0]?.tags.find((t) => tagSlug(t) === tag) ?? tag;
  return { all, items, label };
}

export async function generateMetadata({ params }: PageProps<"/interview-experience/tag/[tag]">): Promise<Metadata> {
  const { tag } = await params;
  const { items, label } = await load(tag);
  if (!items.length) return {};
  const title = `${label} Interview Experiences: Rounds, Questions & Tips`;
  const description = `${items.length} ${label} interview experience${items.length > 1 ? "s" : ""}: rounds, questions asked and preparation tips.`;
  return { title, description, alternates: { canonical: `/interview-experience/tag/${tag}` }, openGraph: { title, description, url: `/interview-experience/tag/${tag}`, type: "website" } };
}

export default async function TagPage({ params }: PageProps<"/interview-experience/tag/[tag]">) {
  const { tag } = await params;
  const { all, items, label } = await load(tag);
  if (!items.length) notFound();
  return (
    <div className="mx-auto max-w-3xl px-4 sm:px-6 pt-14 space-y-16">
      <div>
        <nav aria-label="Breadcrumb" className="font-mono text-sm text-muted mb-6">
          <Link href="/" className="hover:text-accent">Home</Link> / <Link href="/interview-experience" className="hover:text-accent">Interview experience</Link> / <span className="text-accent">{label}</span>
        </nav>
        <SectionTitle h1 n="topic" title={`${label} interview experiences`} sub={`${items.length} experience${items.length > 1 ? "s" : ""} tagged ${label}.`} />
        <TagCloud basePath="/interview-experience" tags={collectTags(all)} active={tag} />
        <ul className="grid gap-4">
          {items.map((i) => (
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
      </div>
      <CtaBand />
    </div>
  );
}
