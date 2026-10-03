-- ميزان V5: صلاحيات المكتب + الإشعارات
-- نفّذ هذا الملف في Supabase SQL Editor بعد تنفيذ المراحل السابقة.

create extension if not exists "pgcrypto";

-- نوع الحساب
alter table public.profiles
add column if not exists role text not null default 'client';

alter table public.profiles
drop constraint if exists profiles_role_check;

alter table public.profiles
add constraint profiles_role_check
check (role in ('client','lawyer','admin'));

-- دالة آمنة لمعرفة موظفي المكتب
create or replace function public.is_staff()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid()
      and role in ('lawyer','admin')
  );
$$;

-- profiles
drop policy if exists "profiles own select" on public.profiles;
drop policy if exists "profiles own update" on public.profiles;
drop policy if exists "profiles_select_own_or_staff" on public.profiles;
drop policy if exists "profiles_update_staff_only" on public.profiles;

create policy "profiles_select_own_or_staff"
on public.profiles for select to authenticated
using (id = auth.uid() or public.is_staff());

create policy "profiles_insert_own"
on public.profiles for insert to authenticated
with check (id = auth.uid());

create policy "profiles_update_staff_only"
on public.profiles for update to authenticated
using (public.is_staff())
with check (public.is_staff());

-- cases
drop policy if exists "cases own select" on public.cases;
drop policy if exists "cases_client_select_own" on public.cases;
drop policy if exists "cases_staff_insert" on public.cases;
drop policy if exists "cases_staff_update" on public.cases;
drop policy if exists "cases_staff_delete" on public.cases;

create policy "cases_client_select_own"
on public.cases for select to authenticated
using (user_id = auth.uid() or public.is_staff());

create policy "cases_staff_insert"
on public.cases for insert to authenticated
with check (public.is_staff());

create policy "cases_staff_update"
on public.cases for update to authenticated
using (public.is_staff()) with check (public.is_staff());

create policy "cases_staff_delete"
on public.cases for delete to authenticated
using (public.is_staff());

-- appointments
drop policy if exists "appointments own select" on public.appointments;
drop policy if exists "appointments_client_select_own" on public.appointments;
drop policy if exists "appointments_staff_insert" on public.appointments;
drop policy if exists "appointments_staff_update" on public.appointments;
drop policy if exists "appointments_staff_delete" on public.appointments;

create policy "appointments_client_select_own"
on public.appointments for select to authenticated
using (user_id = auth.uid() or public.is_staff());

create policy "appointments_staff_insert"
on public.appointments for insert to authenticated
with check (public.is_staff());

create policy "appointments_staff_update"
on public.appointments for update to authenticated
using (public.is_staff()) with check (public.is_staff());

create policy "appointments_staff_delete"
on public.appointments for delete to authenticated
using (public.is_staff());

-- consultations
drop policy if exists "consultations own select" on public.consultation_requests;
drop policy if exists "consultations own insert" on public.consultation_requests;
drop policy if exists "consultations_client_select_own" on public.consultation_requests;
drop policy if exists "consultations_client_insert" on public.consultation_requests;
drop policy if exists "consultations_staff_update" on public.consultation_requests;

create policy "consultations_client_select_own"
on public.consultation_requests for select to authenticated
using (user_id = auth.uid() or public.is_staff());

create policy "consultations_client_insert"
on public.consultation_requests for insert to authenticated
with check (user_id = auth.uid());

create policy "consultations_staff_update"
on public.consultation_requests for update to authenticated
using (public.is_staff()) with check (public.is_staff());

-- notifications
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  body text not null,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.notifications enable row level security;

drop policy if exists "notifications_select_own" on public.notifications;
drop policy if exists "notifications_staff_insert" on public.notifications;
drop policy if exists "notifications_update_own" on public.notifications;

create policy "notifications_select_own"
on public.notifications for select to authenticated
using (user_id = auth.uid() or public.is_staff());

create policy "notifications_staff_insert"
on public.notifications for insert to authenticated
with check (public.is_staff());

create policy "notifications_update_own"
on public.notifications for update to authenticated
using (user_id = auth.uid()) with check (user_id = auth.uid());

grant select, insert, update on public.profiles to authenticated;
grant select, insert, update, delete on public.cases to authenticated;
grant select, insert, update, delete on public.appointments to authenticated;
grant select, insert, update on public.consultation_requests to authenticated;
grant select, insert, update on public.notifications to authenticated;

create index if not exists idx_profiles_role on public.profiles(role);
create index if not exists idx_notifications_user_id on public.notifications(user_id);
