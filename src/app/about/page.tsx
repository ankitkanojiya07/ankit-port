import type { Metadata } from "next";
import SectionTitle from "@/components/SectionTitle";
import SkillsMap from "@/components/SkillsMap";
import { profile, experience, education, research } from "@/lib/content";

export const metadata: Metadata = {
  title: "About Ankit Kanojiya: Tech Lead & Software Engineer",
  description: "Ankit Kanojiya is a Tech Lead and Software Engineer with 3+ years building scalable SaaS platforms, AI-driven systems and mobile apps, including EMPATHY with 20,000+ downloads.",
  alternates: { canonical: "/about" },
};

export default function AboutPage() {
  return (
    <div className="mx-auto max-w-6xl px-4 sm:px-6 pt-14 space-y-20">
      <section>
        <SectionTitle h1 n="about" title="Hi, I'm Ankit Kanojiya" />
        <div className="max-w-3xl space-y-4 text-lg leading-relaxed text-fg/90">
          {profile.intro.map((p) => <p key={p}>{p}</p>)}
        </div>
      </section>

      <section>
        <SectionTitle n="experience" title="Where I've worked" />
        <ol className="relative border-l border-line ml-2 space-y-8">
          {experience.map((e) => (
            <li key={e.company} className="pl-6 relative">
              <span className={`absolute -left-[5px] top-2 h-2.5 w-2.5 rounded-full ${e.current ? "bg-accent" : "bg-line"}`} />
              <p className="font-mono text-xs text-muted">{e.period}</p>
              <h3 className="font-display text-xl font-semibold">{e.role} <span className="text-muted font-normal">· {e.company}</span></h3>
            </li>
          ))}
        </ol>
      </section>

      <section className="grid sm:grid-cols-2 gap-5">
        <div className="rounded-2xl border border-line bg-surface p-6">
          <p className="font-mono text-xs text-accent mb-2">/education</p>
          <h3 className="font-display text-xl font-semibold">{education.school}</h3>
          <p className="text-muted">{education.degree} · {education.year}</p>
        </div>
        <div className="rounded-2xl border border-line bg-surface p-6">
          <p className="font-mono text-xs text-accent mb-2">/research</p>
          <h3 className="font-display text-xl font-semibold">{research.title}</h3>
          <p className="text-muted">{research.kind}</p>
        </div>
      </section>

      <section>
        <SectionTitle n="skills" title="Stack map" sub="Pick a category — the matching part of the system lights up." />
        <SkillsMap />
      </section>
    </div>
  );
}
