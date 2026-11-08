"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
import ThemeToggle from "./ThemeToggle";
import Clock from "./Clock";
import Logo from "./Logo";
import { BOOKING_URL } from "@/lib/site";

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
  return (
    <header className="sticky top-0 z-50 backdrop-blur bg-bg/80 border-b border-line">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 h-14 flex items-center justify-between gap-4">
        <Link href="/" className="font-display font-semibold tracking-tight flex items-center gap-2" onClick={() => setOpen(false)}>
          <Logo className="h-8 w-8" />
          <span className="hidden sm:inline">Ankit Kanojiya</span>
        </Link>
        <nav className="hidden md:flex items-center gap-1" aria-label="Main">
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
