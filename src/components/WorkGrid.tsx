"use client";
import { useState } from "react";
import ProjectCard from "./ProjectCard";
import { categories, type Project } from "@/lib/content";

export default function WorkGrid({ projects }: { projects: Project[] }) {
  const [cat, setCat] = useState<(typeof categories)[number]>("All");
  const list = cat === "All" ? projects : projects.filter((p) => p.category === cat);
  return (
    <>
      <div className="flex flex-wrap gap-2 mb-8" role="group" aria-label="Filter projects">
        {categories.map((c) => (
          <button
            key={c}
            onClick={() => setCat(c)}
            aria-pressed={c === cat}
            className={`px-3 py-1.5 rounded-full text-sm border transition-colors ${
              c === cat ? "bg-accent text-accent-ink border-accent" : "border-line text-muted hover:text-fg hover:border-accent"
            }`}
          >
            {c}
          </button>
        ))}
      </div>
      <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
        {list.map((p, i) => (
          <ProjectCard key={p.id} p={p} index={i} />
        ))}
      </div>
    </>
  );
}
