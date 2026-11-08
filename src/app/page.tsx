import Link from "next/link";
import HeroSystem from "@/components/HeroSystem";
import FlagshipCard from "@/components/FlagshipCard";
import ProjectCard from "@/components/ProjectCard";
import SectionTitle from "@/components/SectionTitle";
import CtaBand from "@/components/CtaBand";
import Reveal from "@/components/Reveal";
import { profile, stats, services } from "@/lib/content";
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
            <p className="font-mono text-xs text-accent mb-4">● for developers · for businesses</p>
            <h1 className="font-display text-4xl sm:text-5xl font-semibold tracking-tight leading-[1.08]">
              Tech news and <span className="text-accent">interview experiences</span> for developers.
              <span className="block text-fg/80 mt-3 text-2xl sm:text-3xl">Software built for businesses.</span>
            </h1>
            <p className="mt-6 text-lg text-muted max-w-xl leading-relaxed">
              Read practical tech news and real interview experiences with the rounds, questions and lessons. Need a product built? I develop web platforms, mobile apps, AI systems and cloud infrastructure.
            </p>
            <div className="mt-8 flex flex-wrap gap-3">
              <Link href="/tech-news" className="rounded-full bg-accent text-accent-ink px-6 py-3 font-medium">Read tech news</Link>
              <Link href="/interview-experience" className="rounded-full border border-line px-6 py-3 font-medium hover:border-accent">Interview experiences</Link>
              <Link href="/work" className="rounded-full border border-line px-6 py-3 font-medium hover:border-accent">See work</Link>
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
        <section className="grid lg:grid-cols-2 gap-10" aria-label="Latest articles">
          <div>
            <SectionTitle n="01" title="Latest tech news" sub="What's happening in software, AI and cloud, explained for working developers." />
            <Feed
              items={news.map((n) => ({ href: `/tech-news/${n.slug}`, title: n.title, meta: new Date(n.created_at).toLocaleDateString("en-GB"), body: n.summary }))}
              empty="Fresh tech news is on its way. Check back soon."
            />
            <Link href="/tech-news" className="inline-block mt-4 font-mono text-sm text-accent">all tech news →</Link>
          </div>
          <div>
            <SectionTitle n="02" title="Interview experiences" sub="Real software interview rounds, questions asked and tips from candidates." />
            <Feed
              items={interviews.map((n) => ({ href: `/interview-experience/${n.slug}`, title: `${n.company} — ${n.role}`, meta: n.outcome, body: n.summary }))}
              empty="The first interview experiences are coming soon."
            />
            <Link href="/interview-experience" className="inline-block mt-4 font-mono text-sm text-accent">all interview experiences →</Link>
          </div>
        </section>

        <section aria-label="Services">
          <SectionTitle n="03" title="Software development services" sub="From idea to production: apps, platforms, cloud and the search visibility to get found." />
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {services.map((s, i) => (
              <Reveal key={s.title} delay={i * 0.04}>
                <Link href="/services" className="block h-full rounded-2xl border border-line bg-surface p-5 hover:border-accent transition-colors">
                  <h3 className="font-display text-lg font-semibold">{s.title}</h3>
                  <p className="text-sm text-muted mt-1.5 line-clamp-3">{s.body}</p>
                </Link>
              </Reveal>
            ))}
          </div>
        </section>

        <CtaBand />

        <section aria-label="Selected work">
          <SectionTitle n="04" title="Proof of work" sub="A mobile app with 20,000+ downloads and live websites built for clients." />
          <FlagshipCard />
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-5 mt-5">
            {featured.map((p, i) => <ProjectCard key={p.id} p={p} index={i} />)}
          </div>
          <Link href="/work" className="inline-block mt-6 font-mono text-sm text-accent">all projects →</Link>
        </section>

        <section aria-label="About" className="max-w-3xl">
          <SectionTitle n="05" title="About Ankit" />
          <p className="text-lg leading-relaxed text-fg/90">{profile.intro[0]}</p>
          <Link href="/about" className="inline-block mt-4 font-mono text-sm text-accent">more about me →</Link>
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
              <h3 className="font-display text-lg font-semibold">{i.title}</h3>
              <p className="text-sm text-muted line-clamp-2">{i.body}</p>
            </Link>
          </Reveal>
        </li>
      ))}
    </ul>
  );
}
