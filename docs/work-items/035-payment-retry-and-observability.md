---
id: payment-retry-observability
aliases: []
tags:
  - work-items
  - payment
  - retries
  - observability
  - replay
depends_on:
  - payment-domain-idempotency
  - payment-provider-fake
  - payment-webhook-ingestion
  - payment-event-handler-pipeline
order: 35
phase: work-items
status: draft
title: Payment Retry and Observability
---

# Payment Retry and Observability

## Goal

- [ ] Make payment processing safe to retry and easy to inspect when something fails.

## Scope

- Add retry policy for webhook processing and downstream event jobs.
- Record processing timestamps, attempts, and failure reasons for payment events.
- Add replay support for failed or unprocessed events.
- Keep duplicate-payment prevention intact across retries and replays.

## Operational Note

- This item is the safety net for the payment pipeline.
- It should not introduce Kafka, RabbitMQ, or other extra queue infrastructure.

## Implementation Plan

- [ ] Add retry configuration for payment event jobs and webhook follow-up work.
- [ ] Store audit data for event processing attempts and failures.
- [ ] Add a replay path for failed events that keeps idempotency guarantees intact.
- [ ] Add tests for retries, duplicate prevention, and replay behavior.

## Affected Docs

- `docs/work-items/031-payment-domain-and-idempotency.md`
- `docs/work-items/033-payment-webhook-ingestion.md`
- `docs/work-items/034-payment-event-handler-pipeline.md`
- `docs/sprints/00-foundation/01-scope.md`

## Affected Ops

- `app/jobs/`
- `app/services/`
- `app/models/`
- `lib/tasks/`
- `spec/jobs/`
- `spec/services/`

## Checklist

- [ ] A failed payment event can be retried without creating a duplicate payment.
- [ ] Event processing leaves an audit trail that helps explain failures.
- [ ] Failed events can be replayed locally or in test.

## Validation

- [ ] Retry and replay specs pass.
- [ ] Duplicate delivery and retry scenarios do not duplicate payment side effects.

## Notes

- Favor simple retryable jobs and audit rows over a separate event-streaming stack.
