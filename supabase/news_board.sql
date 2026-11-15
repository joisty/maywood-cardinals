-- Manual Korean news board tables.
-- Run this once in the Supabase SQL Editor.

create table if not exists public.news (
  id uuid primary key default gen_random_uuid(),
  game_date date not null unique,
  title_ko text not null check (char_length(btrim(title_ko)) between 1 and 200),
  body_ko text not null check (char_length(btrim(body_ko)) between 1 and 20000),
  created_at timestamptz not null default now()
);

create table if not exists public.news_comments (
  id uuid primary key default gen_random_uuid(),
  news_id uuid not null references public.news(id) on delete cascade,
  display_name text not null default '익명'
    check (char_length(btrim(display_name)) between 1 and 80),
  body text not null check (char_length(btrim(body)) between 1 and 2000),
  created_at timestamptz not null default now()
);

create index if not exists news_comments_news_id_created_at_idx
  on public.news_comments (news_id, created_at);

alter table public.news enable row level security;
alter table public.news_comments enable row level security;

grant select on public.news to anon, authenticated;
grant select, insert on public.news_comments to anon, authenticated;

drop policy if exists "Anyone can read news" on public.news;
create policy "Anyone can read news"
  on public.news for select
  to anon, authenticated
  using (true);

drop policy if exists "Anyone can read news comments" on public.news_comments;
create policy "Anyone can read news comments"
  on public.news_comments for select
  to anon, authenticated
  using (true);

drop policy if exists "Anyone can post news comments" on public.news_comments;
create policy "Anyone can post news comments"
  on public.news_comments for insert
  to anon, authenticated
  with check (
    char_length(btrim(display_name)) between 1 and 80
    and char_length(btrim(body)) between 1 and 2000
  );
