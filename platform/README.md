# Singapore SME Growth Platform

Shared production platform for QuoteRecover, TenderBrief, and OpsKit.

## Local setup

1. Copy `.env.example` to `.env.local`.
2. Fill Supabase development credentials.
3. Install dependencies with `npm install`.
4. Apply `supabase/schema.sql` to the development project.
5. Run `npm run dev`.

Real billing, outbound messaging, and production deployment remain disabled until provider credentials and legal/business details are supplied.
