-- Page-load counters: counts every full page load, including refreshes.
-- Run once in the Supabase SQL Editor.

create table if not exists public.page_visit_daily (
  visit_date date primary key,
  visit_count bigint not null default 0 check (visit_count >= 0)
);

create table if not exists public.page_visit_total (
  singleton boolean primary key default true check (singleton),
  total_count bigint not null default 0 check (total_count >= 0)
);

insert into public.page_visit_total (singleton, total_count)
values (true, 0)
on conflict (singleton) do nothing;

alter table public.page_visit_daily enable row level security;
alter table public.page_visit_total enable row level security;

-- The browser can execute the counter function but cannot read or edit its tables.
revoke all on table public.page_visit_daily, public.page_visit_total
  from public, anon, authenticated;

create or replace function public.record_site_visit()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_visit_date date := (pg_catalog.now() at time zone 'America/Los_Angeles')::date;
  v_today_count bigint;
  v_total_count bigint;
begin
  insert into public.page_visit_daily as daily (visit_date, visit_count)
  values (v_visit_date, 1)
  on conflict (visit_date)
  do update set visit_count = daily.visit_count + 1
  returning visit_count into v_today_count;

  update public.page_visit_total
  set total_count = public.page_visit_total.total_count + 1
  where singleton = true
  returning total_count into v_total_count;

  return pg_catalog.jsonb_build_object(
    'today_count', v_today_count,
    'total_count', v_total_count
  );
end;
$$;

revoke all on function public.record_site_visit() from public, anon, authenticated;
grant execute on function public.record_site_visit() to anon, authenticated;
