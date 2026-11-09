export const profile = {
  name: "Ankit Kanojiya",
  role: "Tech Lead · Full-stack & AI systems",
  email: "akanojiya550@gmail.com",
  location: "Delhi, India",
  tagline:
    "I build scalable SaaS platforms, AI-driven systems and real-time backends, and turn complex ideas into products people actually use.",
  intro: [
    "I'm a Software Engineer with 3+ years of experience building scalable SaaS platforms, AI-driven systems, and real-time backend applications. I enjoy turning complex ideas into user-focused products that are reliable, scalable, and impactful.",
    "Over the years I've worked on products across AI, SaaS, and mobile, including EMPATHY, a mental wellness mobile app with 20,000+ downloads across the Google Play Store and Apple App Store.",
    "I'm currently looking for opportunities where I can contribute to high-impact engineering projects and collaborate with talented teams.",
  ],
  socials: [
    { label: "GitHub", href: "https://github.com/ankitkanojiya07" },
    { label: "LinkedIn", href: "https://linkedin.com/in/ankitkanojiya07" },
    { label: "X / Twitter", href: "https://twitter.com/ankitkanojiya07" },
    { label: "Telegram", href: "https://t.me/+919315297507" },
    { label: "Topmate", href: "https://topmate.io/ankitkanojiya07" },
  ],
};

export const stats = [
  { value: "3+", label: "years shipping" },
  { value: "20k+", label: "app downloads" },
  { value: "15+", label: "live projects" },
];

export const experience = [
  { company: "Godown", role: "Tech Lead", period: "Present", current: true },
  { company: "Acutus AI", role: "Software Engineer", period: "Sep 2024 – Oct 2026", current: false },
  { company: "Studyspot India Pvt. Ltd.", role: "Software Engineer", period: "Sep 2023 – Aug 2024", current: false },
];

export const education = {
  school: "University of Delhi",
  degree: "Bachelor of Computer Science",
  year: "2024",
};

export const research = {
  title: "HPC Sustainability",
  kind: "Published research paper",
};

export type SkillGroup = { id: string; label: string; items: string[]; node: string };

/** `node` maps each skill group onto a node of the hero architecture diagram. */
export const skillGroups: SkillGroup[] = [
  { id: "lang", label: "Languages", node: "api", items: ["Python", "JavaScript (ES6+)", "TypeScript", "C++"] },
  { id: "front", label: "Frontend", node: "client", items: ["React.js", "Next.js", "Redux", "Tailwind CSS", "Responsive Design", "Figma"] },
  { id: "back", label: "Backend", node: "api", items: ["Node.js", "FastAPI", "REST APIs", "WebSockets", "Microservices"] },
  { id: "queue", label: "Messaging", node: "queue", items: ["RabbitMQ", "Kafka", "Event-Driven Architecture"] },
  { id: "data", label: "Databases", node: "data", items: ["PostgreSQL", "MySQL", "MongoDB", "Redis (Caching & Message Brokering)"] },
  { id: "cloud", label: "Cloud & DevOps", node: "cloud", items: ["AWS (EC2, S3, Lambda, RDS, VPC)", "Docker", "GitHub Actions", "Jenkins", "CI/CD"] },
  { id: "sys", label: "System Design & Data", node: "queue", items: ["API Design", "Data Pipelines / ETL", "Scalability", "Caching Strategies", "Load Balancing"] },
  { id: "ai", label: "AI / ML & Tooling", node: "ai", items: ["LLM Orchestration", "Multi-LLM Routing", "Prompt Engineering", "Claude Code", "Cursor"] },
  { id: "test", label: "Testing & Quality", node: "api", items: ["Jest", "React Testing Library", "PyTest", "Code Review", "Agile / Scrum"] },
  { id: "obs", label: "Observability", node: "obs", items: ["Grafana", "Prometheus"] },
];

export const services = [
  { title: "App Development", body: "Mobile apps for Android and iOS, built for real users and shipped to the Google Play Store and Apple App Store, like EMPATHY with 20,000+ downloads." },
  { title: "Cloud Management & Application Development", body: "Building scalable, cloud-native applications with modern architecture and best practices, plus expert infrastructure management, optimization, and monitoring for seamless business operations." },
  { title: "Custom Software Development", body: "Tailored software solutions designed to meet your specific business requirements and goals." },
  { title: "Database Development", body: "Efficient database design, development, and optimization for optimal data management." },
  { title: "Web Design & Development", body: "Creative, responsive web designs that deliver exceptional user experiences, built as full-stack websites with modern technologies and frameworks." },
  { title: "SEO & Marketing", body: "Search-friendly websites and marketing support that help the right people find your business and turn visits into enquiries." },
];

export type ProjectCategory = "Product" | "Travel & tourism" | "Business" | "Food & hospitality" | "AI" | "E-commerce & UI";

export type Project = {
  id: string;
  title: string;
  url: string;
  category: ProjectCategory;
  kind: "Product" | "Client work" | "Personal";
  description: string;
  tags: string[];
  featured?: boolean;
  image?: string | null;
};

export const shot = (url: string) =>
  `https://image.thum.io/get/width/1200/crop/760/noanimate/${url}`;

export const flagship = {
  title: "EMPATHY",
  url: "http://empathyapp.in/",
  description:
    "A mental wellness and emotional support mobile app for India, live on the Google Play Store and the Apple App Store with 20,000+ downloads.",
  tags: ["Mobile", "Wellness", "Android", "iOS"],
};

export const staticProjects: Project[] = [
  { id: "discover-culture-india", title: "Discover Culture India", url: "https://www.discovercultureindia.com/", category: "Travel & tourism", kind: "Client work", description: "Travel website showcasing cultural tours and experiences across India.", tags: ["Website", "Tourism"], featured: true },
  { id: "buddhist-tour", title: "Buddhist Tour", url: "https://www.buddhisttour.com/", category: "Travel & tourism", kind: "Client work", description: "Pilgrimage and heritage tour website focused on Buddhist destinations.", tags: ["Website", "Tourism"] },
  { id: "tiger-safaris", title: "Tiger Safaris in India", url: "https://www.tigersafarisinindia.com/", category: "Travel & tourism", kind: "Client work", description: "Wildlife and tiger safari experiences across India's national parks.", tags: ["Website", "Wildlife"], featured: true },
  { id: "ranthambhor", title: "Ranthambhor", url: "https://www.ranthambhor.com/", category: "Travel & tourism", kind: "Client work", description: "Visitor guide and safari information for Ranthambhor National Park.", tags: ["Website", "Wildlife"] },
  { id: "lumorspase", title: "Lumorspase", url: "https://www.lumorspase.com/", category: "Business", kind: "Client work", description: "Business website with a clean, conversion-focused design.", tags: ["Website", "Business"] },
  { id: "ignite-and-rise", title: "IgniteAndRise", url: "https://igniteandris-aoqp.vercel.app/", category: "Business", kind: "Personal", description: "Career guidance platform that directs people to opportunities and HR solutions.", tags: ["Next.js", "Platform"], featured: true },
  { id: "rupee-secure", title: "RupeeSecure", url: "https://fascinating-alpaca-b9dc2d.netlify.app/", category: "Business", kind: "Personal", description: "Loan website with financial services and calculator tools.", tags: ["Fintech", "Calculators"] },
  { id: "fresqua", title: "FresQua", url: "https://fresqua.vercel.app/", category: "Food & hospitality", kind: "Client work", description: "Fresh, modern brand website built for speed and clarity.", tags: ["Website", "Brand"] },
  { id: "basil", title: "Basil Restaurant Menu", url: "https://basil-restaurant-menu.vercel.app/", category: "Food & hospitality", kind: "Client work", description: "Digital menu for a restaurant, designed for quick phone browsing.", tags: ["Menu", "Mobile-first"] },
  { id: "cloud-9", title: "Cloud 9 Bar Menu", url: "https://cloud-9-bar-menu.vercel.app/", category: "Food & hospitality", kind: "Client work", description: "Digital drinks and food menu for a bar, optimized for mobile.", tags: ["Menu", "Mobile-first"] },
  { id: "jaldhara", title: "The Jaldhara", url: "https://the-jaldhara.vercel.app/", category: "Food & hospitality", kind: "Client work", description: "Hospitality website with an elegant showcase and easy contact.", tags: ["Website", "Hospitality"] },
  { id: "rua-ai", title: "Rua Ai", url: "https://rua-ai.netlify.app/", category: "AI", kind: "Personal", description: "AI-powered content generation platform built on NLP.", tags: ["AI", "NLP"], featured: true },
  { id: "fruitables", title: "Fruitables", url: "https://fruitables-vegetables.netlify.app/", category: "E-commerce & UI", kind: "Personal", description: "eCommerce site selling fresh fruits and vegetables.", tags: ["E-commerce", "React"] },
  { id: "slider", title: "Slider", url: "https://sliderby-ankit.netlify.app/", category: "E-commerce & UI", kind: "Personal", description: "Starbucks coffee slider with an interactive product showcase and animations.", tags: ["UI", "Animation"] },
  { id: "cinematic", title: "Cinematic", url: "https://cinematiics.netlify.app/", category: "E-commerce & UI", kind: "Personal", description: "Movie and TV show info site with details for each title.", tags: ["API", "React"] },
];

export const categories: ("All" | ProjectCategory)[] = [
  "All",
  "Travel & tourism",
  "Business",
  "Food & hospitality",
  "AI",
  "E-commerce & UI",
];
