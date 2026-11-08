"use client";
import { useState } from "react";
import ArchDiagram, { nodes, type NodeId } from "./ArchDiagram";
import { skillGroups } from "@/lib/content";

export default function HeroSystem() {
  const [active, setActive] = useState<NodeId | null>(null);
  const groups = active ? skillGroups.filter((g) => g.node === active) : [];
  return (
    <div className="rounded-2xl border border-line bg-surface/60 p-3 sm:p-5">
      <div className="flex items-center gap-1.5 mb-3 px-1">
        <span className="h-2.5 w-2.5 rounded-full bg-line" /><span className="h-2.5 w-2.5 rounded-full bg-line" /><span className="h-2.5 w-2.5 rounded-full bg-line" />
        <span className="ml-3 font-mono text-xs text-muted">system.diagram — hover a node</span>
      </div>
      <ArchDiagram active={active} onSelect={setActive} />
      <div className="mt-3 min-h-[3.5rem] rounded-lg bg-surface-2 px-4 py-3 font-mono text-xs leading-relaxed" aria-live="polite">
        {active ? (
          <>
            <span className="text-accent">$ inspect {nodes[active].label.toLowerCase().replace(" ", "-")}</span>
            <br />
            <span className="text-muted">{groups.flatMap((g) => g.items).join(" · ")}</span>
          </>
        ) : (
          <span className="text-muted">
            <span className="text-accent">$</span> whoami → ankit · tech lead<span className="cursor">▍</span>
          </span>
        )}
      </div>
    </div>
  );
}
