# Production build plan — Singapore SME Growth Platform

## Product decision

Build one multi-tenant SaaS platform with three product modules:

- **QuoteRecover**: CRM, follow-up automation, message templates, activity history, conversion reporting.
- **TenderBrief**: tender ingestion/curation, scoring, digest publishing, subscriber access.
- **OpsKit**: customers, jobs/tasks, checklists, team workflows, reporting.

One identity, billing system, admin console, notification engine, and audit log are shared across all modules.

## Recommended production stack

- Web app/API: Next.js + TypeScript
- Database/auth/storage: Supabase Postgres, Auth, and Storage
- Payments/subscriptions: Stripe Billing
- Email: Resend
- WhatsApp: Meta WhatsApp Cloud API via a provider abstraction
- Background jobs: Trigger.dev or Supabase scheduled functions
- Hosting: Vercel
- Error monitoring: Sentry
- Analytics: privacy-conscious first-party events
- Source control: GitHub

The first build should use provider interfaces so no business logic is tied directly to one vendor.

## Tenant and security model

- `organizations` are tenants.
- Every business record carries `organization_id`.
- Users belong to organizations through `organization_members`.
- Supabase Row Level Security is mandatory on every tenant table.
- Roles: owner, admin, operator, viewer.
- Audit log records auth, billing, data export, imports, message sends, and destructive actions.
- Sensitive customer data is minimized and never stored in application logs.
- Phone numbers and message content are encrypted or access-restricted where appropriate.
- All webhook endpoints verify signatures and are idempotent.

## Shared core modules

1. Marketing site and product comparison.
2. Account creation, login, password reset, email verification.
3. Organization onboarding.
4. Product selection and trial activation.
5. Workspace switcher.
6. Settings, team members, roles, integrations.
7. Billing portal, plans, invoices, cancellation.
8. Notifications and scheduled jobs.
9. Admin console.
10. Backups, CSV/JSON import/export.
11. Audit logs and support tooling.

## Build phases

### Phase 1 — production foundation

- Monorepo and CI.
- Environment validation.
- Database schema and migrations.
- Supabase auth.
- Organization/team model.
- RLS policies.
- App shell and protected routes.
- Product module navigation.
- Test fixtures and seed data.

### Phase 2 — QuoteRecover production module

- Enquiries, quotes, activities, pipeline statuses.
- Follow-up queue and due/overdue views.
- Templates and approval workflow.
- Email sending through Resend.
- WhatsApp integration abstraction and opt-in tracking.
- Scheduled follow-up jobs.
- Conversion metrics.
- CSV import/export.

### Phase 3 — OpsKit production module

- Customers, jobs/tasks, checklists, recurring instances.
- Team assignments and permissions.
- Weekly dashboard.
- Activity history.
- Email notifications.
- CSV/JSON export.

### Phase 4 — TenderBrief production module

- Admin tender intake.
- GeBIZ URL and reference validation.
- Fit scoring and editorial workflow.
- Digest builder.
- Subscriber audience and entitlements.
- Email digest delivery.
- Public archive/landing pages.

No scraping should be added until GeBIZ terms, access method, and reliability are verified.

### Phase 5 — commercial layer

- Stripe products/prices.
- Trial and subscription lifecycle.
- Entitlement checks.
- Customer billing portal.
- Receipts/invoices.
- Refund/cancellation workflows.
- Admin plan overrides.

### Phase 6 — production readiness

- Sentry and structured logs.
- Rate limits and abuse controls.
- Security headers and CSRF protections.
- Backup and restore procedure.
- Privacy policy, terms, PDPA data handling process.
- Monitoring and health checks.
- Production deployment and smoke tests.

## Required external accounts/credentials

These cannot be safely invented or created without the owner's approval:

- Supabase project
- Vercel project/team
- Stripe account and bank/tax details
- Resend account/domain verification
- Meta Business account and WhatsApp Business number
- Production domain/DNS access
- Legal business identity and public support address

Until those are supplied, development can proceed locally with mock providers and test-mode credentials, but real account creation, billing, customer messaging, and public legal claims must remain disabled.

## Launch policy

- Start in test mode.
- Use seed/demo data only during development.
- Do not send WhatsApp/email automatically until opt-in and approval workflows exist.
- Do not charge users until Stripe test flows pass and refund/cancellation policies are published.
- Do not claim production readiness until RLS, webhook verification, backups, and smoke tests pass.
