---
id: client-identity-namespace
title: Client Identity Namespace
phase: decisions
order: 1
aliases: []
tags:
  - decisions
  - auth
  - namespace
---

# Client Identity Namespace

## Decision

Use a `Portal` namespace for client-facing flows and a dedicated request context for identity resolution.

## Proposed Structure

- `app/controllers/portal/*`
- `app/models/current.rb`
- `app/services/portal/client_identity_resolver.rb`

## Rationale

- Keeps client-facing code separate from internal or future admin flows.
- Leaves room to add SSO, JWT, or gateway-based identity later without a large refactor.
- Centralizes identity lookup instead of scattering auth checks across controllers.

## Notes

- The app can operate without a full auth layer in Sprint 0.
- Identity should be injected through request context when available.

## Provisional Feature Flag

- Use a flag such as `AUTH_INTEGRATION_ENABLED` to control whether identity verification is enforced.
- Keep the flag disabled by default during Sprint 0.
- When disabled, route requests through a controlled bypass or null resolver instead of scattering auth conditionals.
- When enabled, swap in the real identity resolver for SSO, token, or gateway-based verification.
