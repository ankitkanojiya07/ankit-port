"use client";

export type NodeId = "client" | "api" | "queue" | "ai" | "data" | "cloud" | "obs";

export const nodes: Record<NodeId, { x: number; y: number; label: string; sub: string; w?: number }> = {
  client: { x: 20, y: 150, label: "Client", sub: "Next.js · React" },
  api: { x: 230, y: 150, label: "API", sub: "FastAPI · Node.js" },
  queue: { x: 440, y: 60, label: "Queue", sub: "Kafka · RabbitMQ" },
  ai: { x: 440, y: 240, label: "AI workers", sub: "Multi-LLM router" },
  data: { x: 650, y: 150, label: "Data", sub: "Postgres · Redis" },
  cloud: { x: 230, y: 320, label: "Cloud", sub: "AWS · Docker · CI/CD" },
  obs: { x: 650, y: 320, label: "Observe", sub: "Prometheus · Grafana" },
};

const edges: [NodeId, NodeId][] = [
  ["client", "api"],
  ["api", "queue"],
  ["queue", "ai"],
  ["ai", "data"],
  ["api", "data"],
  ["cloud", "api"],
  ["data", "obs"],
];

const W = 170;
const H = 64;
const center = (id: NodeId) => ({ x: nodes[id].x + W / 2, y: nodes[id].y + H / 2 });

export default function ArchDiagram({
  active,
  onSelect,
}: {
  active: NodeId | null;
  onSelect: (id: NodeId | null) => void;
}) {
  return (
    <svg viewBox="0 0 860 410" className="w-full h-auto" role="img" aria-label="Architecture diagram of the stack Ankit works with">
      {edges.map(([a, b], i) => {
        const p = center(a);
        const q = center(b);
        const hot = active === a || active === b;
        return (
          <line
            key={i}
            x1={p.x} y1={p.y} x2={q.x} y2={q.y}
            stroke={hot ? "var(--accent)" : "var(--line)"}
            strokeWidth={hot ? 2 : 1.5}
            className="flow-line"
          />
        );
      })}
      {(Object.keys(nodes) as NodeId[]).map((id) => {
        const n = nodes[id];
        const hot = active === id;
        return (
          <g
            key={id}
            tabIndex={0}
            role="button"
            aria-label={`${n.label}: ${n.sub}`}
            onMouseEnter={() => onSelect(id)}
            onMouseLeave={() => onSelect(null)}
            onFocus={() => onSelect(id)}
            onBlur={() => onSelect(null)}
            className="cursor-pointer outline-none"
          >
            <rect
              x={n.x} y={n.y} width={W} height={H} rx={12}
              fill="var(--surface)"
              stroke={hot ? "var(--accent)" : "var(--line)"}
              strokeWidth={hot ? 2 : 1.5}
            />
            {hot && <rect x={n.x - 4} y={n.y - 4} width={W + 8} height={H + 8} rx={15} fill="none" stroke="var(--accent)" opacity={0.25} strokeWidth={6} />}
            <text x={n.x + 16} y={n.y + 28} fill="var(--fg)" fontSize="15" fontWeight="600" fontFamily="var(--font-grotesk)">{n.label}</text>
            <text x={n.x + 16} y={n.y + 48} fill="var(--muted)" fontSize="11" fontFamily="var(--font-jetbrains)">{n.sub}</text>
          </g>
        );
      })}
    </svg>
  );
}
