---
id: order-domain-and-project-rename
aliases: []
tags:
  - work-items
  - ordering
  - projects
  - rename
  - workflow
  - controllers
depends_on:
  - application-boundaries-and-repositories
  - order-workflow-orchestration
order: 44
phase: work-items
status: draft
title: Order Domain and Project Rename
---

# Order Domain and Project Rename

## Goal

- [ ] Recenter the product around `order` as the primary domain concept, keeping `project` only as a temporary compatibility surface during migration.
- [ ] Split the current `project` responsibilities into explicit domains: `catalog` for what is sold, `ordering` for the customer request, `production` for internal work, and `delivery` for the final artifact.

## Scope

- Rename the operator-facing shell from `projects` to `orders`.
- Reframe the existing `Project` model as a compatibility layer around the new order vocabulary.
- Move orchestration and listing concerns into an ordering-oriented namespace.
- Keep client-visible behavior stable during transition.
- Introduce explicit boundaries for:
  - `catalog` = sellable offering
  - `ordering` = customer order / submission
  - `production` = internal fulfillment work
  - `delivery` = final output
- Avoid introducing a vague `asset` abstraction unless a concrete domain role emerges.

## Operational Note

- `Project` is legacy vocabulary, not the target domain name.
- `Order` should be the root business concept for the customer request lifecycle.
- `Offering` should represent what the customer chooses from the catalog.
- `EditingJob` or similar should represent internal production work.
- `Delivery` should represent the final artifact returned to the customer.

## Proposed Naming

- `catalog.offering`
- `ordering.order`
- `production.editing_job`
- `delivery.delivery`
- `projects` only as a migration compatibility shim

## Implementation Plan

- [ ] Define the final domain vocabulary and map each existing `Project` responsibility to its target domain.
- [ ] Introduce `Order` as the primary ordering model or aggregate, with compatibility wrappers where needed.
- [ ] Move the operator listing query out of `app/queries/projects` into the ordering domain namespace.
- [ ] Rename the operator shell routes/controllers/views from `projects` to `orders`.
- [ ] Keep legacy `projects` routes/controllers temporarily as redirects or adapters.
- [ ] Update specs to document the new order vocabulary and migration boundary.
- [ ] Remove `Project` from the visible UI once the ordering shell is complete.

## Checklist

- [ ] The customer request lifecycle is named `order` instead of `project`.
- [ ] The operator shell uses `orders` terminology.
- [ ] `catalog`, `ordering`, `production`, and `delivery` have distinct responsibilities.
- [ ] `project` only exists as transitional compatibility.
- [ ] The listing/query layer lives under the ordering domain.
- [ ] The migration path is explicit and test-covered.

## Validation

- [ ] Specs cover the new order vocabulary.
- [ ] Specs cover compatibility from legacy `project` callsites.
- [ ] Operator-facing pages no longer depend on project terminology in the target path.
- [ ] The rename does not break existing customer-facing behavior during transition.

## Notes

- Prefer a full vocabulary shift over partial renames to avoid confusion.
- If the order root needs a more explicit name than `Order`, consider `SubmissionOrder`, but only if `Order` would be ambiguous in the codebase.
- Keep the migration layered: vocabulary first, compatibility second, cleanup last.
