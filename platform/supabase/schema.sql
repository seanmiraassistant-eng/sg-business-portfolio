create extension if not exists pgcrypto;

create type public.member_role as enum ('owner','admin','operator','viewer');
create type public.product_code as enum ('quoterecover','tenderbrief','opskit');

create table public.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.organization_members (
  organization_id uuid not null references public.organizations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role public.member_role not null default 'operator',
  created_at timestamptz not null default now(),
  primary key (organization_id, user_id)
);

create table public.product_entitlements (
  organization_id uuid not null references public.organizations(id) on delete cascade,
  product public.product_code not null,
  plan text not null default 'trial',
  status text not null default 'active',
  stripe_customer_id text,
  stripe_subscription_id text,
  trial_ends_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (organization_id, product)
);

create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid references public.organizations(id) on delete set null,
  user_id uuid references auth.users(id) on delete set null,
  action text not null,
  entity_type text,
  entity_id text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table public.quoterecover_enquiries (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  customer_name text not null,
  phone text not null,
  email text,
  service text not null,
  location text,
  quote_amount numeric(12,2),
  status text not null default 'new',
  next_action text,
  next_action_at timestamptz,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.opskit_tasks (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  title text not null,
  customer_name text,
  site text,
  due_date date,
  priority text not null default 'normal',
  status text not null default 'backlog',
  notes text,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.tenderbrief_tenders (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  gebiz_reference text not null,
  title text not null,
  procuring_entity text not null,
  official_url text not null,
  closing_at timestamptz not null,
  category text,
  fit_score integer not null default 0 check (fit_score between 0 and 100),
  decision text not null default 'unreviewed',
  summary text,
  internal_notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, gebiz_reference)
);

create index on public.quoterecover_enquiries (organization_id, next_action_at);
create index on public.opskit_tasks (organization_id, due_date);
create index on public.tenderbrief_tenders (organization_id, closing_at);

alter table public.organizations enable row level security;
alter table public.organization_members enable row level security;
alter table public.product_entitlements enable row level security;
alter table public.audit_logs enable row level security;
alter table public.quoterecover_enquiries enable row level security;
alter table public.opskit_tasks enable row level security;
alter table public.tenderbrief_tenders enable row level security;

create or replace function public.is_org_member(target_org uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists(select 1 from public.organization_members m where m.organization_id = target_org and m.user_id = auth.uid());
$$;

create policy org_member_read on public.organizations for select using (public.is_org_member(id));
create policy member_self_read on public.organization_members for select using (user_id = auth.uid() or public.is_org_member(organization_id));
create policy entitlement_member_read on public.product_entitlements for select using (public.is_org_member(organization_id));
create policy audit_member_read on public.audit_logs for select using (public.is_org_member(organization_id));
create policy enquiry_member_all on public.quoterecover_enquiries for all using (public.is_org_member(organization_id)) with check (public.is_org_member(organization_id));
create policy task_member_all on public.opskit_tasks for all using (public.is_org_member(organization_id)) with check (public.is_org_member(organization_id));
create policy tender_member_all on public.tenderbrief_tenders for all using (public.is_org_member(organization_id)) with check (public.is_org_member(organization_id));
