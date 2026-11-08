"use client";
import { useState } from "react";
import ArchDiagram, { type NodeId } from "./ArchDiagram";
import { skillGroups } from "@/lib/content";

export default function SkillsMap() {
  const [gid, setGid] = useState(skillGroups[0].id);
  const group = skillGroups.find((g) => g.id === gid)!;
  return (
    <div className="grid lg:grid-cols-[1fr_1.1fr] gap-8 items-start">
      <div>
        <div role="tablist" aria-label="Skill categories" className="flex flex-wrap gap-2 mb-6">
          {skillGroups.map((g) => (
            <button
              key={g.id}
              role="tab"
              aria-selected={g.id === gid}
              onClick={() => setGid(g.id)}
              className={`px-3 py-1.5 rounded-full text-sm border transition-colors ${
                g.id === gid ? "bg-accent text-accent-ink border-accent" : "border-line text-muted hover:text-fg hover:border-accent"
              }`}
            >
              {g.label}
            </button>
          ))}
        </div>
        <ul className="flex flex-wrap gap-2" role="tabpanel">
          {group.items.map((s) => (
            <li key={s} className="px-3 py-1.5 rounded-lg bg-surface border border-line text-sm">{s}</li>
          ))}
        </ul>
      </div>
      <div className="rounded-2xl border border-line bg-surface/60 p-3 sm:p-5">
        <ArchDiagram active={group.node as NodeId} onSelect={() => {}} />
      </div>
    </div>
  );
}
