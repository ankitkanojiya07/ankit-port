export default function SectionTitle({ n, title, sub, h1 }: { n: string; title: string; sub?: string; h1?: boolean }) {
  const H = h1 ? "h1" : "h2";
  return (
    <div className="mb-8">
      <p className="font-mono text-xs text-accent mb-2">/{n}</p>
      <H className="font-display text-3xl sm:text-4xl font-semibold tracking-tight">{title}</H>
      {sub && <p className="text-muted mt-2 max-w-2xl">{sub}</p>}
    </div>
  );
}
