import type { Metadata } from "next";
import SectionTitle from "@/components/SectionTitle";
import CtaBand from "@/components/CtaBand";
import JsonLd from "@/components/JsonLd";
import Reveal from "@/components/Reveal";
import { services } from "@/lib/content";
import { abs, SITE_NAME } from "@/lib/site";

const DESC = "Software development services: mobile app development, cloud application development, custom software, database development, web design and development, SEO and marketing. Led by a Tech Lead with 3+ years' experience.";
export const metadata: Metadata = {
  title: "Software, App & Cloud Development Services",
  description: DESC,
  alternates: { canonical: "/services" },
  openGraph: { title: "Software, App & Cloud Development Services", description: DESC, url: "/services", type: "website" },
};

const faqs = [
  { q: "What kind of projects do you take on?", a: "Mobile apps for Android and iOS, web platforms and websites, cloud-native applications, AI-driven systems, and database design. If it involves building reliable software, it's worth a conversation." },
  { q: "Do you build both the design and the code?", a: "Yes. I handle responsive web design and full-stack development, so you get one point of contact from idea to a live product." },
  { q: "Can you help get my website found on Google?", a: "Yes. I build sites with search in mind: fast pages, clean structure, proper metadata and structured data, along with marketing support to turn visits into enquiries." },
  { q: "Have you shipped real products?", a: "Yes. EMPATHY, a mental wellness app I worked on, has 20,000+ downloads across the Google Play Store and Apple App Store, and I've delivered live websites for travel, hospitality and business clients." },
  { q: "How do we get started?", a: "Book a free call. We'll talk through what you need, and I'll follow up with the right approach for your project." },
];

export default function ServicesPage() {
  return (
    <div className="mx-auto max-w-6xl px-4 sm:px-6 pt-14 space-y-20">
      <JsonLd
        data={{
          "@context": "https://schema.org",
          "@graph": [
            {
              "@type": "ItemList",
              name: "Software development services",
              itemListElement: services.map((s, i) => ({
                "@type": "ListItem",
                position: i + 1,
                item: { "@type": "Service", name: s.title, description: s.body, provider: { "@type": "Person", name: SITE_NAME, url: abs("/about") } },
              })),
            },
            {
              "@type": "FAQPage",
              mainEntity: faqs.map((f) => ({ "@type": "Question", name: f.q, acceptedAnswer: { "@type": "Answer", text: f.a } })),
            },
          ],
        }}
      />
      <section>
        <SectionTitle h1 n="services" title="Software, app and cloud development services" sub="Web platforms, mobile apps, AI-driven systems and cloud infrastructure, built by a Tech Lead with 3+ years of experience shipping scalable products." />
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
          {services.map((s, i) => (
            <Reveal key={s.title} delay={i * 0.05}>
              <div className="h-full rounded-2xl border border-line bg-surface p-6 hover:border-accent transition-colors">
                <p className="font-mono text-xs text-accent mb-4">{String(i + 1).padStart(2, "0")}</p>
                <h2 className="font-display text-xl font-semibold">{s.title}</h2>
                <p className="text-sm text-muted mt-2 leading-relaxed">{s.body}</p>
              </div>
            </Reveal>
          ))}
        </div>
      </section>

      <section aria-labelledby="faq" className="max-w-3xl">
        <h2 id="faq" className="font-display text-3xl font-semibold tracking-tight mb-6">Frequently asked questions</h2>
        <div className="divide-y divide-line border-y border-line">
          {faqs.map((f) => (
            <details key={f.q} className="group py-4">
              <summary className="cursor-pointer font-medium list-none flex justify-between gap-4">
                {f.q}<span aria-hidden className="text-accent group-open:rotate-45 transition-transform">+</span>
              </summary>
              <p className="text-muted mt-2 leading-relaxed">{f.a}</p>
            </details>
          ))}
        </div>
      </section>

      <CtaBand title="Let's build it" body="Share what you have in mind. A free call is the fastest way to find the right approach." />
    </div>
  );
}
