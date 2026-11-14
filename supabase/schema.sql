-- Run this in the Supabase SQL editor.
-- After running: Authentication > Providers > Email > turn OFF "Allow new users to sign up",
-- then create your own user manually (Authentication > Users > Add user).
-- Any *authenticated* user is treated as admin, so keep sign-ups disabled.

create extension if not exists "pgcrypto";

create table if not exists public.tech_news (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text not null unique,
  summary text not null default '',
  body text not null default '',
  source_url text,
  tags text[] not null default '{}',
  published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.interview_experiences (
  id uuid primary key default gen_random_uuid(),
  company text not null,
  role text not null,
  slug text not null unique,
  outcome text not null default 'Unknown',
  rounds text not null default '',
  summary text not null default '',
  body text not null default '',
  tags text[] not null default '{}',
  published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.learn_articles (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text not null unique,
  category text not null default 'System Design',
  level text not null default 'Beginner',
  summary text not null default '',
  body text not null default '',
  tags text[] not null default '{}',
  published boolean not null default false,
  sort int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  url text not null,
  category text not null,
  kind text not null default 'Personal',
  description text not null default '',
  tags text[] not null default '{}',
  featured boolean not null default false,
  image text,
  sort int not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.contact_messages (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 120),
  email text not null check (char_length(email) between 3 and 200),
  message text not null check (char_length(message) between 1 and 4000),
  created_at timestamptz not null default now()
);

alter table public.tech_news enable row level security;
alter table public.interview_experiences enable row level security;
alter table public.learn_articles enable row level security;
alter table public.projects enable row level security;
alter table public.contact_messages enable row level security;

-- Public can read published content
create policy "public read news" on public.tech_news for select using (published = true);
create policy "public read interviews" on public.interview_experiences for select using (published = true);
create policy "public read learn" on public.learn_articles for select using (published = true);
create policy "public read projects" on public.projects for select using (true);

-- Admin (authenticated) full access
create policy "admin all news" on public.tech_news for all to authenticated using (true) with check (true);
create policy "admin all interviews" on public.interview_experiences for all to authenticated using (true) with check (true);
create policy "admin all learn" on public.learn_articles for all to authenticated using (true) with check (true);
create policy "admin all projects" on public.projects for all to authenticated using (true) with check (true);

-- Contact form: anyone can insert, only admin can read/delete
create policy "anyone insert message" on public.contact_messages for insert to anon, authenticated with check (true);
create policy "admin read messages" on public.contact_messages for select to authenticated using (true);
create policy "admin delete messages" on public.contact_messages for delete to authenticated using (true);
