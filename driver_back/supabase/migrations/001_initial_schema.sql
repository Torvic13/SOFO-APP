create extension if not exists pgcrypto;

create table if not exists public.trips (
  id uuid primary key default gen_random_uuid(),
  unit_id text not null,
  corridor text not null,
  status text not null default 'active' check (status in ('active', 'finished')),
  started_at timestamptz not null default now(),
  finished_at timestamptz
);

create unique index if not exists one_active_trip_per_unit
  on public.trips (unit_id) where status = 'active';

create table if not exists public.bus_current_locations (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id) on delete cascade,
  unit_id text not null unique,
  corridor text not null,
  latitude double precision not null check (latitude between -90 and 90),
  longitude double precision not null check (longitude between -180 and 180),
  recorded_at timestamptz not null default now()
);

create table if not exists public.bus_location_history (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id) on delete cascade,
  unit_id text not null,
  corridor text not null,
  latitude double precision not null check (latitude between -90 and 90),
  longitude double precision not null check (longitude between -180 and 180),
  recorded_at timestamptz not null default now()
);

create index if not exists location_history_trip_recorded
  on public.bus_location_history (trip_id, recorded_at desc);

alter table public.trips enable row level security;
alter table public.bus_current_locations enable row level security;
alter table public.bus_location_history enable row level security;

-- El backend usa service_role, que omite RLS. No expongas esa clave en Flutter.
