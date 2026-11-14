"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useRef, useState } from "react";
import ThemeToggle from "./ThemeToggle";
import Clock from "./Clock";
import Logo from "./Logo";
import { BOOKING_URL } from "@/lib/site";
import { learnCategories } from "@/lib/content";

const links = [
  { href: "/tech-news", label: "Tech News" },
  { href: "/interview-experience", label: "Interview Experience" },
  { href: "/services", label: "Services" },
  { href: "/work", label: "Work" },
  { href: "/about", label: "About" },
];

export default function Nav() {
  const path = usePathname();
  const [open, setOpen] = useState(false);
  const [learnOpen, setLearnOpen] = useState(false);
  const learnRef = useRef<HTMLDivElement>(null);
  const learnActive = path.startsWith("/learn");

  // Close dropdown on outside click.
  useEffect(() => {
    function onDown(e: MouseEvent) {
      if (learnRef.current && !learnRef.current.contains(e.target as Node)) setLearnOpen(false);
    }
    document.addEventListener("mousedown", onDown);
    return () => document.removeEventListener("mousedown", onDown);
  }, []);

  return (
    <header className="sticky top-0 z-50 backdrop-blur bg-bg/80 border-b border-line">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 h-14 flex items-center justify-between gap-4">
        <Link href="/" className="font-display font-semibold tracking-tight flex items-center gap-2" onClick={() => setOpen(false)}>
          <Logo className="h-8 w-8" />
          <span className="hidden sm:inline">Ankit Kanojiya</span>
        </Link>
        <nav className="hidden md:flex items-center gap-1" aria-label="Main">
          <div
            ref={learnRef}
            className="relative"
            onMouseEnter={() => setLearnOpen(true)}
            onMouseLeave={() => setLearnOpen(false)}
          >
            <button
              type="button"
              onClick={() => setLearnOpen((o) => !o)}
              aria-expanded={learnOpen}
              aria-haspopup="menu"
              className={`px-3 py-1.5 rounded-full text-sm transition-colors inline-flex items-center gap-1 ${
                learnActive ? "text-fg bg-surface-2" : "text-muted hover:text-fg"
              }`}
            >
              Learn
              <svg width="10" height="10" viewBox="0 0 10 10" aria-hidden className={`transition-transform ${learnOpen ? "rotate-180" : ""}`}>
                <path d="M1 3l4 4 4-4" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
              </svg>
            </button>
            {learnOpen && (
              <div role="menu" className="absolute left-0 top-full pt-2 w-60">
                <ul className="rounded-2xl border border-line bg-bg/95 backdrop-blur shadow-lg p-2">
                  <li>
                    <Link href="/learn" role="menuitem" onClick={() => setLearnOpen(false)} className="block px-3 py-2 rounded-lg text-sm text-fg hover:bg-surface-2">All guides</Link>
                  </li>
                  <li aria-hidden className="my-1 border-t border-line" />
                  {learnCategories.map((c) => (
                    <li key={c.slug}>
                      <Link href={`/learn/${c.slug}`} role="menuitem" onClick={() => setLearnOpen(false)} className="block px-3 py-2 rounded-lg text-sm text-muted hover:text-fg hover:bg-surface-2">
                        {c.label}
                      </Link>
                    </li>
                  ))}
                </ul>
              </div>
            )}
          </div>
          {links.map((l) => (
            <Link
              key={l.href}
              href={l.href}
              className={`px-3 py-1.5 rounded-full text-sm transition-colors ${
                path.startsWith(l.href) ? "text-fg bg-surface-2" : "text-muted hover:text-fg"
              }`}
            >
              {l.label}
            </Link>
          ))}
        </nav>
        <div className="flex items-center gap-3">
          <span className="hidden lg:block"><Clock /></span>
          <ThemeToggle />
          <a href={BOOKING_URL} target="_blank" rel="noopener noreferrer" className="hidden sm:inline-block rounded-full bg-accent text-accent-ink px-4 py-1.5 text-sm font-medium">Book a call</a>
          <button
            className="md:hidden h-9 px-3 rounded-full border border-line text-sm"
            onClick={() => setOpen((o) => !o)}
            aria-expanded={open}
            aria-label="Menu"
          >
            {open ? "Close" : "Menu"}
          </button>
        </div>
      </div>
      {open && (
        <nav className="md:hidden border-t border-line px-4 py-3 flex flex-col" aria-label="Mobile">
          <Link href="/learn" onClick={() => setOpen(false)} className="py-2.5 text-fg font-medium">Learn</Link>
          <div className="flex flex-col pl-3 border-l border-line ml-1 mb-1">
            {learnCategories.map((c) => (
              <Link key={c.slug} href={`/learn/${c.slug}`} onClick={() => setOpen(false)} className="py-1.5 text-sm text-muted hover:text-fg">
                {c.label}
              </Link>
            ))}
          </div>
          {links.map((l) => (
            <Link key={l.href} href={l.href} onClick={() => setOpen(false)} className="py-2.5 text-muted hover:text-fg">
              {l.label}
            </Link>
          ))}
          <Link href="/contact" onClick={() => setOpen(false)} className="py-2.5 text-muted hover:text-fg">Contact</Link>
          <a href={BOOKING_URL} target="_blank" rel="noopener noreferrer" className="mt-2 rounded-full bg-accent text-accent-ink px-4 py-2.5 text-center font-medium">Book a call ↗</a>
        </nav>
      )}
    </header>
  );
}
