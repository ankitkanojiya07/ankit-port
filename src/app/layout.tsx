import type { Metadata } from "next";
import { Inter, Space_Grotesk, JetBrains_Mono } from "next/font/google";
import "./globals.css";
import Nav from "@/components/Nav";
import Footer from "@/components/Footer";
import JsonLd from "@/components/JsonLd";
import { SITE_URL, SITE_NAME } from "@/lib/site";

const inter = Inter({ variable: "--font-inter", subsets: ["latin"] });
const grotesk = Space_Grotesk({ variable: "--font-grotesk", subsets: ["latin"] });
const mono = JetBrains_Mono({ variable: "--font-jetbrains", subsets: ["latin"] });

const TITLE = "Tech News & Interview Experiences + Software Development Services";
const DESC =
  "Practical tech news and real interview experiences for developers, plus software, mobile app, cloud and AI development services for businesses. By Ankit Kanojiya, Tech Lead.";

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: { default: `${TITLE} | ${SITE_NAME}`, template: `%s | ${SITE_NAME}` },
  description: DESC,
  keywords: [
    "tech news", "interview experience", "software interview questions", "developer interview experiences",
    "software development services", "mobile app development", "cloud application development",
    "AI development", "hire software engineer India", "Ankit Kanojiya",
  ],
  authors: [{ name: SITE_NAME, url: SITE_URL }],
  alternates: { canonical: "/" },
  openGraph: { type: "website", siteName: SITE_NAME, title: TITLE, description: DESC, url: "/", locale: "en_IN" },
  twitter: { card: "summary_large_image", title: TITLE, description: DESC },
  robots: { index: true, follow: true },
};

const themeScript = `try{var t=localStorage.getItem('theme')||'dark';document.documentElement.dataset.theme=t}catch(e){document.documentElement.dataset.theme='dark'}`;

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="en" data-theme="dark" suppressHydrationWarning className={`${inter.variable} ${grotesk.variable} ${mono.variable}`}>
      <head>
        <script dangerouslySetInnerHTML={{ __html: themeScript }} />
      </head>
      <body className="min-h-screen flex flex-col">
        <JsonLd
          data={{
            "@context": "https://schema.org",
            "@graph": [
              { "@type": "WebSite", name: SITE_NAME, url: SITE_URL, description: DESC, inLanguage: "en" },
              {
                "@type": "Person", name: SITE_NAME, url: SITE_URL, jobTitle: "Tech Lead",
                address: { "@type": "PostalAddress", addressLocality: "Delhi", addressCountry: "IN" },
                sameAs: ["https://github.com/ankitkanojiya07", "https://linkedin.com/in/ankitkanojiya07", "https://twitter.com/ankitkanojiya07", "https://topmate.io/ankitkanojiya07"],
              },
              {
                "@type": "ProfessionalService", name: `${SITE_NAME} — Software Development Services`, url: `${SITE_URL}/services`,
                areaServed: "Worldwide", email: "akanojiya550@gmail.com",
                serviceType: ["Mobile app development", "Cloud application development", "Custom software development", "Database development", "Web design and development", "SEO and marketing"],
              },
            ],
          }}
        />
        <Nav />
        <main className="flex-1">{children}</main>
        <Footer />
      </body>
    </html>
  );
}
