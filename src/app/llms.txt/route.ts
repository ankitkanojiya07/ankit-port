import { abs, SITE_URL, SITE_NAME, BOOKING_URL } from "@/lib/site";
import { profile, services, experience, education, skillGroups, flagship, staticProjects, learnCategoryByLabel } from "@/lib/content";
import { getNews, getInterviews, getLearnArticles } from "@/lib/data";

export const revalidate = 3600;

export async function GET() {
  const [news, interviews, learn] = await Promise.all([getNews(), getInterviews(), getLearnArticles()]);
  const lines: string[] = [
    `# ${SITE_NAME}`,
    "",
    `> ${profile.role}. ${profile.tagline}`,
    "",
    ...profile.intro,
    "",
    `Location: ${profile.location}`,
    `Contact: ${profile.email} (or the form at ${abs("/contact")})`,
    `Book a call: ${BOOKING_URL}`,
    `Sitemap: ${SITE_URL}/sitemap.xml`,
    "",
    "## Pages",
    `- [Home](${abs("/")}): Overview, skills and featured work`,
    `- [About](${abs("/about")}): Background, experience and education`,
    `- [Services](${abs("/services")}): What I can build for you`,
    `- [Work](${abs("/work")}): Portfolio of shipped projects`,
    `- [Learn](${abs("/learn")}): Guides on system design, frontend, backend, DSA, DevOps, databases and AI/ML`,
    `- [Tech News](${abs("/tech-news")}): Short write-ups on tech news`,
    `- [Interview Experience](${abs("/interview-experience")}): Real interview experiences and tips`,
    `- [Contact](${abs("/contact")}): Send a message`,
    "",
    "## Services",
    ...services.map((s) => `- ${s.title}: ${s.body}`),
    "",
    "## Experience",
    ...experience.map((e) => `- ${e.role}, ${e.company} (${e.period})`),
    `- Education: ${education.degree}, ${education.school} (${education.year})`,
    "",
    "## Skills",
    ...skillGroups.map((g) => `- ${g.label}: ${g.items.join(", ")}`),
    "",
    "## Projects",
    `- [${flagship.title}](${flagship.url}): ${flagship.description}`,
    ...staticProjects.map((p) => `- [${p.title}](${p.url}): ${p.description}`),
    "",
    "## Links",
    ...profile.socials.map((s) => `- [${s.label}](${s.href})`),
  ];
  if (learn.length) {
    lines.push("", "## Learn", ...learn.map((a) => `- [${a.title}](${abs(`/learn/${learnCategoryByLabel(a.category)?.slug ?? "system-design"}/${a.slug}`)}) [${a.category}]: ${a.summary}`));
  }
  if (news.length) {
    lines.push("", "## Tech News", ...news.map((n) => `- [${n.title}](${abs(`/tech-news/${n.slug}`)}): ${n.summary}`));
  }
  if (interviews.length) {
    lines.push("", "## Interview Experiences", ...interviews.map((i) => `- [${i.company} – ${i.role}](${abs(`/interview-experience/${i.slug}`)}): ${i.summary}`));
  }
  return new Response(lines.join("\n") + "\n", {
    headers: { "Content-Type": "text/plain; charset=utf-8" },
  });
}
