# Manual Korean news board setup

1. In the Supabase SQL Editor, run [supabase/news_board.sql](supabase/news_board.sql).
2. In Table Editor, open `public.news` and insert one row for each game date:
   - `game_date`: the date as `YYYY-MM-DD`
   - `title_ko`: the Korean article headline
   - `body_ko`: the Korean story text
   - Leave `id` and `created_at` blank so their defaults are used.
3. Open **News board** from the login screen or the rankings page. Articles appear newest first. Readers can open a story's comment thread and post with an optional display name.

The article body is displayed as plain text with line breaks preserved. The board currently shows the latest 100 articles and up to 300 comments for an open article. A unique `game_date` allows one story per day; edit that day's row in Supabase to replace it.

Comments are publicly readable and writable. Names are labels only: a logged-in member's current name is prefilled, but anyone can edit it or post as `익명`. Delete unwanted comments from the Supabase Table Editor.

This version has no AI connection or scheduled publishing. AI-written Korean stories can be pasted into `title_ko` and `body_ko` manually.

## Page-load counter

Run [supabase/page_visit_counter.sql](supabase/page_visit_counter.sql) once in the Supabase SQL Editor. The site then increments today's and all-time counts on every full page load. Refreshes count again; switching between the rankings and news views inside the app does not. The daily count uses America/Los_Angeles time.
