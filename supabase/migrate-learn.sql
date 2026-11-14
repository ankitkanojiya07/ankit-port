-- Additive migration for the Learn section. Safe to run on an existing database.
-- Run this in the Supabase SQL editor, then run seed-learn.sql.

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

alter table public.learn_articles enable row level security;

drop policy if exists "public read learn" on public.learn_articles;
create policy "public read learn" on public.learn_articles for select using (published = true);

drop policy if exists "admin all learn" on public.learn_articles;
create policy "admin all learn" on public.learn_articles for all to authenticated using (true) with check (true);
