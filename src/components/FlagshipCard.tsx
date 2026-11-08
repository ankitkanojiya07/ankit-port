import { flagship } from "@/lib/content";

export default function FlagshipCard() {
  return (
    <a
      href={flagship.url}
      target="_blank"
      rel="noopener noreferrer"
      className="group relative block rounded-3xl border border-line bg-surface overflow-hidden hover:border-accent transition-colors"
    >
      <div className="absolute -right-24 -top-24 h-72 w-72 rounded-full bg-accent opacity-10 blur-3xl" aria-hidden />
      <div className="relative p-6 sm:p-10 grid md:grid-cols-[1.3fr_1fr] gap-8 items-center">
        <div>
          <p className="font-mono text-xs text-accent mb-3">FLAGSHIP PRODUCT · LIVE</p>
          <h3 className="font-display text-4xl sm:text-5xl font-semibold tracking-tight">{flagship.title}</h3>
          <p className="text-muted mt-4 max-w-lg leading-relaxed">{flagship.description}</p>
          <div className="flex flex-wrap gap-2 mt-5">
            {flagship.tags.map((t) => (
              <span key={t} className="text-xs font-mono px-2.5 py-1 rounded-md bg-surface-2 text-muted">{t}</span>
            ))}
          </div>
          <p className="mt-6 font-mono text-sm text-accent group-hover:translate-x-1 transition-transform inline-block">empathyapp.in ↗</p>
        </div>
        <div className="grid grid-cols-2 gap-3 text-center">
          <div className="rounded-2xl bg-surface-2 p-5">
            <p className="font-display text-3xl font-semibold text-accent">20k+</p>
            <p className="text-xs text-muted mt-1">downloads</p>
          </div>
          <div className="rounded-2xl bg-surface-2 p-5">
            <p className="font-display text-3xl font-semibold text-accent">2</p>
            <p className="text-xs text-muted mt-1">stores · Play & App Store</p>
          </div>
        </div>
      </div>
    </a>
  );
}
