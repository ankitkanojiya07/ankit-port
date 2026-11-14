import { hasSupabase } from "@/lib/supabase/server";
import { createPublicClient as createClient } from "@/lib/supabase/public";
import { staticProjects, type Project } from "@/lib/content";
import { slugify } from "@/lib/slug";

export type News = {
  id: string; title: string; slug: string; summary: string; body: string;
  source_url: string | null; tags: string[]; published: boolean; created_at: string;
};
export type Interview = {
  id: string; company: string; role: string; slug: string; outcome: string; rounds: string;
  summary: string; body: string; tags: string[]; published: boolean; created_at: string;
};
export type LearnArticle = {
  id: string; title: string; slug: string; category: string; level: string;
  summary: string; body: string; tags: string[]; published: boolean; sort: number; created_at: string;
};

async function safe<T>(fn: () => PromiseLike<{ data: T | null; error: unknown }>, fallback: T): Promise<T> {
  if (!hasSupabase()) return fallback;
  try {
    const { data, error } = await fn();
    return error || !data ? fallback : data;
  } catch {
    return fallback;
  }
}

export async function getNews(limit?: number): Promise<News[]> {
  if (!hasSupabase()) return [];
  const sb = createClient();
  return safe(() => {
    let q = sb.from("tech_news").select("*").eq("published", true).order("created_at", { ascending: false });
    if (limit) q = q.limit(limit);
    return q;
  }, [] as News[]);
}

export async function getNewsBySlug(slug: string): Promise<News | null> {
  if (!hasSupabase()) return null;
  const sb = createClient();
  const rows = await safe(() => sb.from("tech_news").select("*").eq("slug", slug).eq("published", true).limit(1), [] as News[]);
  return rows[0] ?? null;
}

export async function getInterviews(limit?: number): Promise<Interview[]> {
  if (!hasSupabase()) return [];
  const sb = createClient();
  return safe(() => {
    let q = sb.from("interview_experiences").select("*").eq("published", true).order("created_at", { ascending: false });
    if (limit) q = q.limit(limit);
    return q;
  }, [] as Interview[]);
}

export async function getInterviewBySlug(slug: string): Promise<Interview | null> {
  if (!hasSupabase()) return null;
  const sb = createClient();
  const rows = await safe(() => sb.from("interview_experiences").select("*").eq("slug", slug).eq("published", true).limit(1), [] as Interview[]);
  return rows[0] ?? null;
}

export async function getLearnArticles(limit?: number): Promise<LearnArticle[]> {
  if (!hasSupabase()) return [];
  const sb = createClient();
  return safe(() => {
    let q = sb.from("learn_articles").select("*").eq("published", true)
      .order("sort", { ascending: true }).order("created_at", { ascending: false });
    if (limit) q = q.limit(limit);
    return q;
  }, [] as LearnArticle[]);
}

export async function getLearnByCategory(categoryLabel: string): Promise<LearnArticle[]> {
  if (!hasSupabase()) return [];
  const sb = createClient();
  return safe(() => sb.from("learn_articles").select("*").eq("published", true).eq("category", categoryLabel)
    .order("sort", { ascending: true }).order("created_at", { ascending: false }), [] as LearnArticle[]);
}

export async function getLearnBySlug(slug: string): Promise<LearnArticle | null> {
  if (!hasSupabase()) return null;
  const sb = createClient();
  const rows = await safe(() => sb.from("learn_articles").select("*").eq("slug", slug).eq("published", true).limit(1), [] as LearnArticle[]);
  return rows[0] ?? null;
}

export async function getProjects(): Promise<Project[]> {
  if (!hasSupabase()) return staticProjects;
  const sb = createClient();
  const rows = await safe(
    () => sb.from("projects").select("*").order("sort", { ascending: true }),
    [] as Array<Project & { featured: boolean }>,
  );
  if (!rows.length) return staticProjects;
  return rows.map((r) => ({ ...r, id: String(r.id) })) as Project[];
}

export { slugify } from "@/lib/slug";

export const tagSlug = (t: string) => slugify(t);

export function collectTags(items: { tags: string[] }[]): { tag: string; slug: string; count: number }[] {
  const map = new Map<string, { tag: string; slug: string; count: number }>();
  for (const it of items) {
    for (const t of it.tags) {
      const s = tagSlug(t);
      if (!s) continue;
      const cur = map.get(s);
      if (cur) cur.count++;
      else map.set(s, { tag: t, slug: s, count: 1 });
    }
  }
  return [...map.values()].sort((a, b) => b.count - a.count || a.tag.localeCompare(b.tag));
}
