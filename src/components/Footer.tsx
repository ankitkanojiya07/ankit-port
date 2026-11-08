import Link from "next/link";
import { profile } from "@/lib/content";
import Logo from "./Logo";

import { BOOKING_URL } from "@/lib/site";

const explore = [
  { href: "/tech-news", label: "Tech News" },
  { href: "/interview-experience", label: "Interview Experience" },
  { href: "/services", label: "Services" },
  { href: "/work", label: "Work" },
  { href: "/about", label: "About" },
];

export default function Footer() {
  return (
    <footer className="border-t border-line mt-24">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 py-10 grid gap-8 sm:grid-cols-2 lg:grid-cols-4 text-sm text-muted">
        <div>
          <Link href="/" className="inline-flex items-center gap-2 mb-2" aria-label="Home">
            <Logo className="h-8 w-8" />
            <span className="font-display text-fg font-semibold">Ankit Kanojiya</span>
          </Link>
          <p>{profile.location}</p>
          <a href={`mailto:${profile.email}`} className="hover:text-accent">{profile.email}</a>
        </div>
        <nav aria-label="Explore" className="flex flex-col gap-2">
          <p className="font-mono text-xs text-fg/70 mb-1">Explore</p>
          {explore.map((l) => <Link key={l.href} href={l.href} className="hover:text-accent">{l.label}</Link>)}
        </nav>
        <nav aria-label="Get in touch" className="flex flex-col gap-2">
          <p className="font-mono text-xs text-fg/70 mb-1">Get in touch</p>
          <a href={BOOKING_URL} target="_blank" rel="noopener noreferrer" className="hover:text-accent">Book appointment ↗</a>
          <Link href="/contact" className="hover:text-accent">Contact us</Link>
        </nav>
        <div className="flex flex-col gap-2">
          <p className="font-mono text-xs text-fg/70 mb-1">Elsewhere</p>
          <div className="flex flex-wrap gap-x-5 gap-y-2">
            {profile.socials.map((s) => (
              <a key={s.label} href={s.href} target="_blank" rel="noopener noreferrer" className="hover:text-accent">{s.label}</a>
            ))}
            <Link href="/sign-in" aria-label="Admin sign in" className="opacity-40 hover:opacity-100">·</Link>
          </div>
        </div>
      </div>
    </footer>
  );
}
