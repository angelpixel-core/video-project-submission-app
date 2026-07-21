---
id: payment-provider-fake
aliases: []
tags:
  - work-items
  - payment
  - provider
  - adapter
  - fake
depends_on:
  - payment-domain-idempotency
order: 32
phase: work-items
status: draft
title: Fake Payment Provider Adapter
---

# Fake Payment Provider Adapter

## Goal

- [ ] Introduce a provider adapter that can accept a payment request synchronously and return a fake provider reference.

## Scope

- Define a provider interface that the domain can call without knowing the concrete provider.
- Implement a fake provider that returns accepted or processing results synchronously.
- Keep card validation local and independent from provider selection.
- Leave the asynchronous confirmation for the webhook pipeline.

## Operational Note

- This provider is a stand-in for a real gateway.
- It should be swappable without changing the payment domain or webhook code.

## Implementation Plan

- [ ] Add a `PaymentProvider` interface and a `PaymentProvider::Fake` implementation.
- [ ] Return a provider payment id plus an accepted/processing status from the fake provider.
- [ ] Keep provider-specific logic behind the adapter boundary.
- [ ] Add tests for successful and declined fake provider responses.

## Affected Docs

- `docs/work-items/031-payment-domain-and-idempotency.md`
- `docs/sprints/00-foundation/01-scope.md`

## Affected Ops

- `app/services/payment_provider/`
- `app/services/`
- `spec/services/`

## Checklist

- [ ] The payment domain can call a provider through a stable interface.
- [ ] The fake provider returns a deterministic result for test submissions.
- [ ] Provider switching does not require domain model changes.

## Validation

- [ ] Provider adapter specs pass.
- [ ] The fake provider can be used in development and test.

## Notes

- Keep the fake provider deterministic enough for repeatable tests, but allow it to emit provider ids and eventual confirmation states.
