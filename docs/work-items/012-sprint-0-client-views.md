---
id: sprint-0-client-views
aliases: []
tags:
  - work-items
  - sprint-0
  - ui
  - views
  - forms
depends_on:
  - sprint-0-data-model
  - testing-foundation
  - frontend-toolchain
order: 12
phase: work-items
status: draft
title: Sprint 0 Client Views
---

# Sprint 0 Client Views

## Goal

- [ ] Implement the client-facing project index and order flow for Sprint 0.

## Scope

- Project index view for the logged-in client.
- Order project view for selecting video types and entering project details.
- Payment modal UI for the simulated checkout step.
- Submission behavior that creates the project, persists video type selections, and redirects back to the project index.
- Keep the flow aligned with the Sprint 0 data model already implemented.

## Operational Note

- This work item is the UI layer for the Sprint 0 order flow.
- The domain model already exists; this item should consume it rather than redesign it.

## Implementation Plan

- [ ] Add the project index and order project screens.
- [ ] Wire the video type selection UI to the existing `VideoType` and `VideoTypeSelection` models.
- [ ] Add the payment modal and submission flow.
- [ ] Create the project and selection records on submit.
- [ ] Redirect back to the project index after a successful submission.
- [ ] Add minimal UI or controller specs needed to protect the flow.

## Affected Docs

- `docs/sprints/00-foundation/04-client-views.md`
- `docs/sprints/00-foundation/03-data-model.md`
- `docs/sprints/00-foundation/07-acceptance-criteria.md`

## Affected Ops

- `app/controllers/`
- `app/views/`
- `app/helpers/` if needed
- `app/javascript/` if the modal needs client-side behavior
- `spec/requests/` or `spec/system/` depending on the implementation style

## Checklist

- [ ] The client can see a project index.
- [ ] The client can start an order from the UI.
- [ ] Video type selections are persisted through the existing data model.
- [ ] The payment step completes and redirects successfully.

## Validation

- [ ] The relevant UI or request specs pass.
- [ ] The order flow creates the expected records.
- [ ] The UI matches the Sprint 0 client-views doc.

## Notes

- Favor the smallest UI surface that satisfies the Sprint 0 docs.
- Keep the flow simple and deterministic; this is a simulated checkout.
