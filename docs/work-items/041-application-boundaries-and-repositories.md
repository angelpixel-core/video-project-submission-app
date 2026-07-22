---
id: application-boundaries-and-repositories
aliases: []
tags:
  - work-items
  - architecture
  - repositories
  - use-cases
  - controllers
  - modularization
depends_on:
  - payment-outbound-notifications
  - payment-invoice-generation-and-storage
order: 41
phase: work-items
status: draft
title: Application Boundaries and Repositories
---

# Application Boundaries and Repositories

## Goal

- [ ] Modularize the application boundaries so controllers stay thin, business workflows move to use cases/handlers, and local persistence access is isolated behind repositories.

## Scope

- Split HTTP concerns from domain orchestration.
- Extract controller logic into use cases / handlers.
- Introduce repositories only for local persistence where they add value.
- Keep repositories focused on `ActiveRecord` access, not external integrations.
- Remove demo-only flags from domain objects and move them to test/demo tooling.
- Prepare the codebase for more explicit domain workflows without over-abstracting.

## Operational Note

- `service` should mean external integration or side effect.
- `repository` should mean local persistence access.
- `use case` / `handler` should orchestrate business steps and talk to repositories/services.
- Controllers should only parse request input and render responses.

## Implementation Plan

- [ ] Identify the highest-value flows to extract first.
- [ ] Move payment and notification orchestration out of controllers into use cases.
- [ ] Add repositories for local models only where repeated query/write logic exists.
- [ ] Keep domain objects free of HTTP/demo concerns.
- [ ] Define a consistent folder/package structure for application, domain, repository, and service layers.
- [ ] Add specs around the extracted boundaries.

## Affected Docs

- `docs/work-items/031-payment-domain-and-idempotency.md`
- `docs/work-items/034-payment-event-handler-pipeline.md`
- `docs/work-items/039-payment-outbound-notifications.md`
- `docs/work-items/040-payment-invoice-generation-and-storage.md`

## Affected Ops

- `app/controllers/`
- `app/services/`
- `app/repositories/`
- `app/domain/`
- `app/jobs/`
- `spec/unit/`
- `spec/requests/`

## Checklist

- [ ] Controllers no longer contain business workflow orchestration.
- [ ] Repositories own repeated local data access.
- [ ] Use cases coordinate domain steps and side effects.
- [ ] Demo/test flags are not part of domain models.
- [ ] The architecture is easier to extend for invoices, mail, and future payment methods.

## Validation

- [ ] Specs cover the extracted use cases.
- [ ] Specs cover repository behavior.
- [ ] Controllers remain thin and stable.

## Notes

- Start small: one flow first, then repeat the pattern.
- Don’t introduce repositories everywhere by default.
- Route modularization can be a follow-up if controller extraction forces it.
