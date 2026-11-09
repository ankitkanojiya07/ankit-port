import Link from "next/link";
import HeroSystem from "@/components/HeroSystem";
import FlagshipCard from "@/components/FlagshipCard";
import ProjectCard from "@/components/ProjectCard";
import SectionTitle from "@/components/SectionTitle";
import Reveal from "@/components/Reveal";
import { profile, stats } from "@/lib/content";
import { getProjects, getNews, getInterviews } from "@/lib/data";

export const revalidate = 300;

export default async function Home() {
  const [projects, news, interviews] = await Promise.all([getProjects(), getNews(3), getInterviews(3)]);
  const featured = projects.filter((p) => p.featured).slice(0, 3);
  return (
    <>
      <section className="relative overflow-hidden">
        <div className="grid-bg absolute inset-0" aria-hidden />
        <div className="relative mx-auto max-w-6xl px-4 sm:px-6 pt-16 pb-20 grid lg:grid-cols-[1fr_1.15fr] gap-12 items-center">
          <div>
            <p className="font-mono text-xs text-accent mb-4">● available for new opportunities</p>
            <h1 className="font-display text-5xl sm:text-6xl font-semibold tracking-tight leading-[1.05]">
              Systems that scale.<br />
              <span className="text-accent">Products that stick.</span>
            </h1>
            <p className="mt-6 text-lg text-muted max-w-xl leading-relaxed">{profile.tagline}</p>
            <div className="mt-8 flex flex-wrap gap-3">
              <Link href="/work" className="rounded-full bg-accent text-accent-ink px-6 py-3 font-medium">See my work</Link>
              <Link href="/contact" className="rounded-full border border-line px-6 py-3 font-medium hover:border-accent">Get in touch</Link>
            </div>
            <dl className="mt-10 grid grid-cols-3 gap-4 max-w-md">
              {stats.map((s) => (
                <div key={s.label}>
                  <dt className="font-display text-3xl font-semibold">{s.value}</dt>
                  <dd className="text-xs text-muted mt-0.5">{s.label}</dd>
                </div>
              ))}
            </dl>
          </div>
          <HeroSystem />
        </div>
      </section>

      <div className="mx-auto max-w-6xl px-4 sm:px-6 space-y-24">
        <section>
          <SectionTitle n="01" title="Featured work" />
          <FlagshipCard />
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-5 mt-5">
            {featured.map((p, i) => <ProjectCard key={p.id} p={p} index={i} />)}
          </div>
          <Link href="/work" className="inline-block mt-6 font-mono text-sm text-accent">all projects →</Link>
        </section>

        <section className="grid lg:grid-cols-2 gap-10">
          <div>
            <SectionTitle n="02" title="Tech news" sub="What I'm reading and noticing in tech." />
            <Feed items={news.map((n) => ({ href: `/tech-news/${n.slug}`, title: n.title, meta: new Date(n.created_at).toLocaleDateString("en-GB"), body: n.summary }))} empty="First tech news coming soon." />
            <Link href="/tech-news" className="inline-block mt-4 font-mono text-sm text-accent">all tech news →</Link>
          </div>
          <div>
            <SectionTitle n="03" title="Interview experience" sub="Rounds, questions and lessons from real interviews." />
            <Feed items={interviews.map((n) => ({ href: `/interview-experience/${n.slug}`, title: `${n.company} — ${n.role}`, meta: n.outcome, body: n.summary }))} empty="First experiences coming soon." />
            <Link href="/interview-experience" className="inline-block mt-4 font-mono text-sm text-accent">all experiences →</Link>
          </div>
        </section>
      </div>
    </>
  );
}

function Feed({ items, empty }: { items: { href: string; title: string; meta: string; body: string }[]; empty: string }) {
  if (!items.length) return <p className="text-muted border border-dashed border-line rounded-2xl p-6">{empty}</p>;
  return (
    <ul className="divide-y divide-line border-y border-line">
      {items.map((i) => (
        <li key={i.href}>
          <Reveal>
            <Link href={i.href} className="block py-4 hover:text-accent transition-colors">
              <p className="font-mono text-xs text-muted">{i.meta}</p>
              <p className="font-display text-lg font-semibold">{i.title}</p>
              <p className="text-sm text-muted line-clamp-2">{i.body}</p>
            </Link>
          </Reveal>
        </li>
      ))}
    </ul>
  );
}
