---
id: payment-outbound-notifications
aliases: []
tags:
  - work-items
  - payment
  - notifications
  - mail
  - outbox
  - workflow
depends_on:
  - payment-event-handler-pipeline
  - payment-retry-observability
  - mail-delivery-environment-setup
  - notification-delivery-channels
order: 39
phase: work-items
status: draft
title: Payment Outbound Notifications
---

# Payment Outbound Notifications

## Goal

- [ ] Persist payment state changes and their outbound notification intents atomically, then deliver emails and other subscribers asynchronously after commit.

## Scope

- Capture payment success and payment failure notifications as part of the same business transaction that changes payment state.
- Keep the controller thin; the payment state transition and notification intent should happen in a use case / handler layer.
- Deliver emails asynchronously after commit so the transaction does not wait on slow side effects.
- Allow multiple subscribers for the same payment event, including email and logging.
- Keep demo/test flags out of domain objects and model parameters.

## Operational Note

- The transaction should own the state change and the notification intent.
- The actual mail delivery must happen outside the transaction, via job or outbox processing.
- Logger-based notification is a first-class subscriber, not a special case in controller code.

## Implementation Plan

- [ ] Introduce a domain event or notification intent for payment state transitions.
- [ ] Persist outbound notification intent in the same transaction that updates payment status.
- [ ] Add an async worker to dispatch payment notification intents after commit.
- [ ] Implement customer mail notifications for payment success and payment failure.
- [ ] Wire logger notifications as an additional subscriber.
- [ ] Add specs for atomic state change + intent persistence, plus async delivery behavior.

## Affected Docs

- `docs/work-items/031-payment-domain-and-idempotency.md`
- `docs/work-items/034-payment-event-handler-pipeline.md`
- `docs/work-items/035-payment-retry-and-observability.md`
- `docs/work-items/018-mail-delivery-environment-setup.md`

## Affected Ops

- `app/controllers/`
- `app/services/`
- `app/jobs/`
- `app/mailers/`
- `app/models/`
- `spec/requests/`
- `spec/system/`
- `spec/mailers/`
- `spec/unit/`

## Checklist

- [ ] Payment success persists the state change and notification intent atomically.
- [ ] Payment failure persists the state change and notification intent atomically.
- [ ] The email send happens async after the transaction commits.
- [ ] Multiple notification subscribers can react to the same payment event.
- [ ] Demo/test-only flags are not part of domain models or controller params.

## Validation

- [ ] Specs cover success and failure notification paths.
- [ ] Specs cover async delivery and duplicate-safe behavior.
- [ ] The flow remains safe if a notification worker retries.

## Notes

- Prefer a small orchestration layer over putting side-effect logic in controllers.
- If a repository abstraction is introduced later, keep it focused on local persistence and not on external side effects.
