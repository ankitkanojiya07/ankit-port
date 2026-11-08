"use client";

export default function ThemeToggle() {
  const toggle = () => {
    const next = document.documentElement.dataset.theme === "dark" ? "light" : "dark";
    document.documentElement.dataset.theme = next;
    try { localStorage.setItem("theme", next); } catch {}
  };
  return (
    <button
      onClick={toggle}
      aria-label="Toggle theme"
      className="h-9 w-9 rounded-full border border-line grid place-items-center text-muted hover:text-fg hover:border-accent transition-colors"
    >
      <span aria-hidden className="font-mono text-sm">◐</span>
    </button>
  );
}
