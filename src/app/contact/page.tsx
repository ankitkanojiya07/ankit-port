import type { Metadata } from "next";
import SectionTitle from "@/components/SectionTitle";
import ContactForm from "./ContactForm";
import { profile } from "@/lib/content";

export const metadata: Metadata = {
  title: "Contact: Hire a Software Developer",
  description: "Get in touch to hire Ankit Kanojiya for software, mobile app, cloud or AI development, or to talk about a project or role.",
  alternates: { canonical: "/contact" },
};

export default function ContactPage() {
  return (
    <div className="mx-auto max-w-6xl px-4 sm:px-6 pt-14 grid md:grid-cols-2 gap-12">
      <div>
        <SectionTitle h1 n="contact" title="Let's build something" sub="Have a project, role or idea? Send a message or reach out directly." />
        <dl className="space-y-4">
          <div><dt className="font-mono text-xs text-muted">Email</dt><dd><a className="hover:text-accent" href={`mailto:${profile.email}`}>{profile.email}</a></dd></div>
          <div><dt className="font-mono text-xs text-muted">Location</dt><dd>{profile.location}</dd></div>
          <div>
            <dt className="font-mono text-xs text-muted">Elsewhere</dt>
            <dd className="flex flex-wrap gap-x-4 gap-y-1">
              {profile.socials.map((s) => <a key={s.label} href={s.href} target="_blank" rel="noopener noreferrer" className="hover:text-accent">{s.label}</a>)}
            </dd>
          </div>
        </dl>
      </div>
      <ContactForm />
    </div>
  );
}
