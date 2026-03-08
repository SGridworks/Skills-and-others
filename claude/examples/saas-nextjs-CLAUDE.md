# SaaS Application (Next.js + Supabase + Stripe)

## Stack
- Next.js 15 (App Router)
- Supabase (Auth, Database, Storage)
- Stripe (Payments)
- Tailwind CSS + shadcn/ui
- Playwright (E2E tests)

## Critical Rules
- ALWAYS use `getUser()`, NEVER `getSession()` for auth checks
- ALWAYS use `createServerClient` in Server Components, `createBrowserClient` in Client Components
- ALL database tables MUST have Row Level Security (RLS) policies
- ALL API inputs validated with Zod
- NEVER expose Stripe secret key to client code
- Webhook handlers MUST verify Stripe signatures

## Project Structure

```
app/
  (auth)/          # Auth routes (login, signup, callback)
  (dashboard)/     # Protected routes
  api/             # API routes
    webhooks/      # Stripe webhooks
components/        # Shared UI components
lib/
  supabase/        # Supabase client factories
  stripe/          # Stripe utilities
  validations/     # Zod schemas
```

## Commands

- `npm run dev` — Development server
- `npm run build` — Production build
- `npm test` — Unit tests
- `npx playwright test` — E2E tests
- `npm run lint` — ESLint
- `npx tsc --noEmit` — Type check
