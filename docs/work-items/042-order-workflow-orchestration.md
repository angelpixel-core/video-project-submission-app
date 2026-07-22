---
id: order-workflow-orchestration
aliases: []
tags:
  - work-items
  - payment
  - orders
  - workflow
  - orchestration
  - saga
depends_on:
  - application-boundaries-and-repositories
  - payment-outbound-notifications
  - payment-invoice-generation-and-storage
order: 42
phase: work-items
status: draft
title: Order Workflow Orchestration
---

# Order Workflow Orchestration

## Goal

- [ ] Model the order/payment flow as an explicit workflow with clear steps for payment validation, payment capture, success handling, invoice creation, and follow-up notifications.

## Scope

- Introduce a workflow/orchestrator layer for order processing.
- Model payment-related business steps as ordered stages instead of controller-driven branching.
- Separate pre-payment validation from payment capture/confirmation.
- Allow downstream steps to run only after the payment state reaches the expected checkpoint.
- Keep the workflow extensible for future payment methods and fulfillment paths.
- Avoid coupling the workflow to a single provider or a single notification type.

## Operational Note

- This is the business flow layer, not transport code.
- The workflow should coordinate repositories, use cases, mailers, and jobs.
- If a step fails, the workflow should make the failure point explicit and retry-safe.
- This layer should be able to grow into a saga-style flow if we later need compensating actions.

## Implementation Plan

- [ ] Define the order workflow entrypoint and the list of stages.
- [ ] Add a pre-payment validation step before capture.
- [ ] Add a payment confirmation step that hands off to the outbound notification flow.
- [ ] Add a post-confirmation step that can trigger invoice generation/storage.
- [ ] Make the workflow step boundaries explicit and testable.
- [ ] Add specs for success, validation failure, and downstream-step failure.

## Affected Docs

- `docs/work-items/031-payment-domain-and-idempotency.md`
- `docs/work-items/039-payment-outbound-notifications.md`
- `docs/work-items/040-payment-invoice-generation-and-storage.md`
- `docs/work-items/041-application-boundaries-and-repositories.md`

## Affected Ops

- `app/services/`
- `app/jobs/`
- `app/models/`
- `app/controllers/`
- `spec/unit/`
- `spec/system/`

## Checklist

- [ ] Payment validation happens before capture.
- [ ] Payment capture/confirmation is a distinct workflow step.
- [ ] Downstream mail/invoice steps only run after success.
- [ ] Workflow steps are explicit and retry-safe.
- [ ] Future payment methods can plug into the same flow.

## Validation

- [ ] Specs cover the workflow stages and failure points.
- [ ] Specs cover downstream handoff after successful payment.
- [ ] Workflow remains readable and does not collapse back into controller logic.

## Notes

- Start with the minimal workflow we need now.
- If compensation becomes necessary, evolve this into a saga-style implementation later.
- Keep provider-specific details out of the workflow core.
