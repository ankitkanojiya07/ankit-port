import Link from "next/link";
import { BOOKING_URL } from "@/lib/site";

export default function CtaBand({
  title = "Need software, an app or cloud work done?",
  body = "I build scalable web platforms, mobile apps, AI-driven systems and cloud infrastructure for businesses. Tell me what you're building.",
}: { title?: string; body?: string }) {
  return (
    <section aria-labelledby="cta-title" className="relative overflow-hidden rounded-3xl border border-line bg-surface p-8 sm:p-12">
      <div className="absolute -left-20 -bottom-20 h-64 w-64 rounded-full bg-accent opacity-10 blur-3xl" aria-hidden />
      <div className="relative max-w-2xl">
        <p className="font-mono text-xs text-accent mb-3">WORK WITH ME</p>
        <h2 id="cta-title" className="font-display text-3xl sm:text-4xl font-semibold tracking-tight">{title}</h2>
        <p className="text-muted mt-3 leading-relaxed">{body}</p>
        <div className="mt-6 flex flex-wrap gap-3">
          <a href={BOOKING_URL} target="_blank" rel="noopener noreferrer" className="rounded-full bg-accent text-accent-ink px-6 py-3 font-medium">Book a free call ↗</a>
          <Link href="/services" className="rounded-full border border-line px-6 py-3 font-medium hover:border-accent">View services</Link>
        </div>
      </div>
    </section>
  );
}
