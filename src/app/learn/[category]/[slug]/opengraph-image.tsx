import { ogCard, ogSize } from "@/lib/og";
import { getLearnBySlug } from "@/lib/data";

export const alt = "Learn article";
export const size = ogSize;
export const contentType = "image/png";

export default async function Image({ params }: { params: Promise<{ category: string; slug: string }> }) {
  const { slug } = await params;
  const a = await getLearnBySlug(slug);
  return ogCard({ kicker: a ? `Learn · ${a.category}` : "Learn", title: a?.title ?? "Learn software engineering", sub: a?.tags.slice(0, 4).join(" · ") });
}
