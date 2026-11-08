import type { Metadata } from "next";
import SectionTitle from "@/components/SectionTitle";
import FlagshipCard from "@/components/FlagshipCard";
import WorkGrid from "@/components/WorkGrid";
import { getProjects } from "@/lib/data";

export const metadata: Metadata = {
  title: "Work: Mobile App & Website Projects",
  description: "Selected work: EMPATHY mental wellness app with 20,000+ downloads, plus live websites and apps for travel, hospitality, business and AI clients.",
  alternates: { canonical: "/work" },
};
export const revalidate = 300;

export default async function WorkPage() {
  const projects = await getProjects();
  return (
    <div className="mx-auto max-w-6xl px-4 sm:px-6 pt-14">
      <SectionTitle h1 n="work" title="Selected work" sub="One mobile product, and live websites and apps built for clients and as personal projects." />
      <FlagshipCard />
      <h3 className="font-display text-xl font-semibold mt-14 mb-5">Live projects <span className="text-muted font-normal">({projects.length})</span></h3>
      <WorkGrid projects={projects} />
    </div>
  );
}
