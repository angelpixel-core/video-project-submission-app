---
id: invoicing-presentation-and-adapter-taxonomy
aliases:
  - billing-presentation-and-adapter-taxonomy
tags:
  - work-items
  - billing
  - invoicing
  - architecture
  - presentation
  - adapters
depends_on:
  - application-boundaries-and-repositories
order: 48
phase: work-items
status: done
title: Invoicing Presentation and Adapter Taxonomy
---

# Invoicing Presentation and Adapter Taxonomy

## Goal

- [x] Document a clear invoicing folder taxonomy that separates domain logic, application orchestration, outbound integrations, inbound entry points, and presentation concerns.

## Scope

- Define what belongs in `domain/`, `application/`, `adapters/`, and `presentation/` under `invoicing`.
- Clarify why fiscal providers are outbound adapters.
- Clarify why HTML/JSON/stream/binary renderers belong in presentation.
- Document how Rails controllers, routes, and views consume invoicing output without entering the bounded context.

## Affected Docs

- `docs/decisions/10-invoicing-presentation-and-adapter-taxonomy.md`
- `app/domains/invoicing/README.md`
- `app/domains/billing/README.md`
- `app/domains/billing/domain/README.md`
- `app/domains/billing/application/README.md`
- `app/domains/billing/adapters/README.md`
- `app/domains/billing/presentation/README.md`

## Affected Ops

- `app/domains/billing/`
- `docs/decisions/`
- `docs/work-items/`

## Checklist

- [x] Taxonomy is written down in one architecture decision.
- [x] Route maps exist in the physical billing source tree.
- [x] Presentation is separated from outbound integrations.
- [x] Rails framework concerns are documented as external to the bounded context.

## Validation

- [x] Documentation reflects the existing physical billing layout, the intended future `presentation/` layer, and the product vocabulary shift to invoicing.

## Notes

- This is documentation-only and does not change runtime behavior.
