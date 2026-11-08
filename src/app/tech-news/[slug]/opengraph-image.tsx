import { ogCard, ogSize } from "@/lib/og";
import { getNewsBySlug } from "@/lib/data";

export const alt = "Tech news article";
export const size = ogSize;
export const contentType = "image/png";

export default async function Image({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const n = await getNewsBySlug(slug);
  return ogCard({ kicker: "Tech news", title: n?.title ?? "Tech news for developers", sub: n?.tags.slice(0, 4).join(" · ") });
}
