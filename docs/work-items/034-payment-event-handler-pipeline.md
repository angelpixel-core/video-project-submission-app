---
id: payment-event-handler-pipeline
aliases: []
tags:
  - work-items
  - payment
  - events
  - pipeline
  - handler
depends_on:
  - payment-webhook-ingestion
order: 34
phase: work-items
status: draft
title: Payment Event Handler Pipeline
---

# Payment Event Handler Pipeline

## Goal

- [ ] Process stored payment webhook events and drive the payment state machine from those events.

## Scope

- Build a handler/dispatcher that consumes stored webhook events.
- Map provider event types to payment state transitions.
- Update the related `Project` only when the payment reaches a confirmed terminal state.
- Keep business logic out of the webhook controller.

## Operational Note

- This is the domain pipeline, not transport code.
- It should be safe to replay the same stored event without double-applying effects.

## Implementation Plan

- [ ] Add a `PaymentEventHandler` or dispatcher that loads stored webhook events and routes them by event type.
- [ ] Apply payment state transitions only after idempotency and ordering checks succeed.
- [ ] Update project submission state or downstream notifications when payment confirmation is received.
- [ ] Add tests for success, duplicate, and out-of-order event handling.

## Affected Docs

- `docs/work-items/033-payment-webhook-ingestion.md`
- `docs/sprints/00-foundation/01-scope.md`

## Affected Ops

- `app/services/`
- `app/models/`
- `app/jobs/`
- `spec/services/`
- `spec/jobs/`

## Checklist

- [ ] Stored webhook events can be dispatched to a dedicated handler.
- [ ] Confirmed payment events update payment state exactly once.
- [ ] Project state changes happen only after the payment pipeline confirms success.

## Validation

- [ ] Service and job specs cover event replay and duplicate handling.
- [ ] The pipeline can be rerun without creating duplicate payments.

## Notes

- Prefer a small dispatcher plus focused handlers over a single giant service object.
