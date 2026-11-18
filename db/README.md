# Neon PostgreSQL — ONIX AI Connect

This directory is the initial Neon-specific schema foundation.

## Secure setup
1. Keep the rotated Neon secrets only in Vercel Environment Variables.
2. Confirm `DATABASE_URL` resolves in the `onix-ai` Vercel project.
3. Open the **Neon SQL Editor** for the dedicated `onix-ai-connect-db` database.
4. Review and run `migrations/001_initial.sql` once, using the SQL editor.
5. Verify the tables exist in the Neon database browser.
6. For a local connection, keep DATABASE_URL in a private `.env.local` (never commit it), and run `npm run db:check` after loading those variables into the process.

## Security requirements before customer data
The migration provisions relational tables and foreign keys but does **not** yet implement sign-in or row-level security. Do not accept real customer data until authenticated membership-based access and tenant isolation have been implemented and tested. The dashboard still uses browser localStorage and does not write to Neon.

Do not reuse the draft `supabase/schema.sql` on Neon; it references Supabase `auth.users`. The canonical schema for Neon is under `db/migrations`.

## Planned next milestone
- Implement sign-in with a supported identity provider.
- Add secure organization onboarding and invitation flow.
- Restrict every CRUD operation by authenticated organization membership.
- Implement database RLS / least-privilege database roles.
- Replace browser-only prototype storage with server-side APIs.
- Test cross-tenant access denial and deployment build before activating production traffic.
