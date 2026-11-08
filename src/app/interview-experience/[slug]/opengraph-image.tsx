import { ogCard, ogSize } from "@/lib/og";
import { getInterviewBySlug } from "@/lib/data";

export const alt = "Interview experience";
export const size = ogSize;
export const contentType = "image/png";

export default async function Image({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const i = await getInterviewBySlug(slug);
  return ogCard({
    kicker: "Interview experience",
    title: i ? `${i.company} ${i.role} interview experience` : "Software interview experiences",
    sub: i ? [i.outcome, i.rounds].filter(Boolean).join(" · ") : undefined,
  });
}
