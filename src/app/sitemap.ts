import type { MetadataRoute } from "next";
import { abs } from "@/lib/site";
import { getNews, getInterviews, collectTags } from "@/lib/data";

export const revalidate = 3600;

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const [news, interviews] = await Promise.all([getNews(), getInterviews()]);
  const now = new Date();
  const fixed: [string, number][] = [
    ["/", 1], ["/tech-news", 0.9], ["/interview-experience", 0.9], ["/services", 0.9],
    ["/work", 0.7], ["/about", 0.6], ["/contact", 0.6],
  ];
  return [
    ...fixed.map(([path, priority]) => ({ url: abs(path), lastModified: now, priority })),
    ...news.map((n) => ({ url: abs(`/tech-news/${n.slug}`), lastModified: new Date(n.created_at), priority: 0.8 })),
    ...collectTags(news).map((t) => ({ url: abs(`/tech-news/tag/${t.slug}`), lastModified: now, priority: 0.5 })),
    ...collectTags(interviews).map((t) => ({ url: abs(`/interview-experience/tag/${t.slug}`), lastModified: now, priority: 0.5 })),
    ...interviews.map((i) => ({ url: abs(`/interview-experience/${i.slug}`), lastModified: new Date(i.created_at), priority: 0.8 })),
  ];
}
