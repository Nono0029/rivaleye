-- RivalEye — Schema Supabase
-- A executer dans le SQL Editor du dashboard Supabase

-- Table des concurrents
create table if not exists public.competitors (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    name text not null,
    type text not null default 'site' check (type in ('site', 'app', 'logiciel', 'boite')),
    url text default '',
    color text default 'red',
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- Index par utilisateur
create index if not exists idx_competitors_user on public.competitors(user_id);

-- RLS (Row Level Security)
alter table public.competitors enable row level security;

create policy "Users can view own competitors"
    on public.competitors for select
    using (auth.uid() = user_id);

create policy "Users can insert own competitors"
    on public.competitors for insert
    with check (auth.uid() = user_id);

create policy "Users can update own competitors"
    on public.competitors for update
    using (auth.uid() = user_id);

create policy "Users can delete own competitors"
    on public.competitors for delete
    using (auth.uid() = user_id);

-- Fonction updated_at automatique
create or replace function public.handle_updated_at()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

drop trigger if exists set_competitors_updated_at on public.competitors;
create trigger set_competitors_updated_at
    before update on public.competitors
    for each row
    execute function public.handle_updated_at();
