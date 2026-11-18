-- ONIX AI Connect: draft relational model, not yet connected to UI.
-- Run on a dedicated Supabase project, after reviewing permissions.
create extension if not exists pgcrypto;
create table if not exists public.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  segment text not null,
  created_at timestamptz not null default now()
);
create table if not exists public.memberships (
  organization_id uuid not null references public.organizations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('owner','admin','agent')),
  created_at timestamptz not null default now(),
  primary key (organization_id,user_id)
);
create table if not exists public.assistants (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  name text not null,
  tone text not null default 'Consultivo',
  instructions text not null default '',
  created_at timestamptz not null default now()
);
create table if not exists public.contacts (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  whatsapp_id text not null,
  display_name text,
  created_at timestamptz not null default now(),
  unique (organization_id,whatsapp_id)
);
create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  contact_id uuid not null references public.contacts(id) on delete cascade,
  assigned_to uuid references auth.users(id),
  status text not null default 'open' check (status in ('open','assigned','closed')),
  ai_paused boolean not null default false,
  updated_at timestamptz not null default now()
);
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  direction text not null check(direction in ('in','out')),
  body text not null,
  provider_message_id text,
  created_at timestamptz not null default now(),
  unique (organization_id,provider_message_id)
);
-- Enable row-level security by default; policies need authenticated membership.
alter table public.organizations enable row level security;
alter table public.memberships enable row level security;
alter table public.assistants enable row level security;
alter table public.contacts enable row level security;
alter table public.conversations enable row level security;
alter table public.messages enable row level security;

create or replace function public.is_org_member(target_org uuid)
returns boolean language sql stable security definer
set search_path = ''
as $$ select exists (
  select 1 from public.memberships
  where organization_id = target_org and user_id = (select auth.uid())
); $$;

-- Read policies. Mutations should go through audited backend operations until
-- owner/admin membership policies and invitation flows are implemented.
create policy "members read their organizations" on public.organizations
for select to authenticated using (public.is_org_member(id));
create policy "members read their memberships" on public.memberships
for select to authenticated using (public.is_org_member(organization_id));
create policy "members read assistants" on public.assistants
for select to authenticated using (public.is_org_member(organization_id));
create policy "members read contacts" on public.contacts
for select to authenticated using (public.is_org_member(organization_id));
create policy "members read conversations" on public.conversations
for select to authenticated using (public.is_org_member(organization_id));
create policy "members read messages" on public.messages
for select to authenticated using (public.is_org_member(organization_id));
