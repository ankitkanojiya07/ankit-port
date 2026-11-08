/** Logo mark: an "A" drawn as a tiny system diagram (3 nodes, 2 links, 1 dashed data flow). */
export default function Logo({ className = "h-8 w-8" }: { className?: string }) {
  return (
    <svg viewBox="0 0 32 32" className={className} role="img" aria-label="Ankit Kanojiya logo" fill="none">
      <rect x="0.75" y="0.75" width="30.5" height="30.5" rx="8" fill="var(--surface)" stroke="var(--line)" strokeWidth="1.5" />
      <g stroke="var(--accent)" strokeWidth="2" strokeLinecap="round">
        <path d="M16 7 L8 25 M16 7 L24 25" />
        <path d="M11.4 18 H20.6" strokeDasharray="1.5 3" strokeWidth="1.8" className="flow-line" />
      </g>
      <g fill="var(--accent)">
        <circle cx="16" cy="7" r="2.6" />
        <circle cx="8" cy="25" r="2.2" />
        <circle cx="24" cy="25" r="2.2" />
      </g>
    </svg>
  );
}
