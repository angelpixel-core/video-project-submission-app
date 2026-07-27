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

- [ ] Model the order/payment flow as an explicit workflow with clear steps for validation, capture/confirmation, success handling, invoice creation, and follow-up notifications.

## Scope

- Introduce a workflow/orchestrator layer for order processing.
- Model payment-related business steps as ordered stages instead of controller-driven branching.
- Separate pre-payment validation from payment capture/confirmation.
- Allow downstream steps to run only after the payment state reaches the expected checkpoint.
- Keep the workflow extensible for future payment methods and fulfillment paths.
- Avoid coupling the workflow to a single provider or a single notification type.

## Workflow Map

### Current Flow Today

```text
ProjectsController#update
  -> Projects::Application::Commands::UpdateProject
    -> Projects::Application::Commands::SubmitProject (when finalize=1)
      -> pre-flight validation (selections present)
      -> Project.transaction / project.with_lock
      -> project.submit!
      -> sync selections
      -> Payments::Application::Commands::CreatePayment
        -> create or reuse active payment
        -> provider gateway call
        -> update payment state to processing / failed
      -> NotificationJob.perform_later(project.id)
        -> Projects::Notifications::Service
          -> create project notification
          -> Projects::Notifications::Dispatcher
```

### Target Workflow

```text
Workflow entrypoint
  Orders::Application::Commands::ProcessOrderPayment
    |
    |-- Step 1: validate_submission
    |     - requires selections
    |     - validates order/project attributes
    |
    |-- Step 2: capture_or_confirm_payment
    |     - delegates to Payments::Application::Commands::CreatePayment
    |     - persists payment attempt and provider state
    |
    |-- Step 3: success_handling
    |     - records success checkpoint
    |     - hands off to follow-up jobs
    |
    |-- Step 4: enqueue_follow_up_work
          - notification dispatch
          - invoice generation/storage
          - provider-agnostic post-confirmation work
```

### Step Boundaries

- `validate_submission` should fail fast before any side effects.
- `capture_or_confirm_payment` should own payment state transitions only.
- `success_handling` should run only after the payment reaches the expected checkpoint.
- `enqueue_follow_up_work` should be idempotent and safe to retry.

### Current File Mapping

- `Projects::Application::Commands::SubmitProject` owns the current workflow orchestration.
- `Payments::Application::Commands::CreatePayment` owns payment capture/provider confirmation.
- `Payments::Application::Handlers::GenerateInvoiceJob` owns invoice generation/storage after success.
- `Payments::Application::Handlers::DispatchPaymentNotificationJob` owns payment status email delivery.
- `Projects::Notifications::Service` and `NotificationJob` own project submission notifications.

## Operational Note

- This is the business flow layer, not transport code.
- The workflow should coordinate repositories, use cases, mailers, and jobs.
- If a step fails, the workflow should make the failure point explicit and retry-safe.
- This layer should be able to grow into a saga-style flow if we later need compensating actions.

## Implementation Plan

- [ ] Introduce `Orders::Application::Commands::ProcessOrderPayment` as the orchestration entrypoint.
- [ ] Extract `validate_submission` as a named step that runs before any payment side effects.
- [ ] Keep payment capture/confirmation inside `Payments::Application::Commands::CreatePayment`.
- [ ] Add an explicit success checkpoint that runs only after payment reaches the expected state.
- [ ] Trigger invoice and notification follow-up work only from the success checkpoint.
- [ ] Make the workflow boundaries explicit and testable with one spec per stage.
- [ ] Add specs for success, validation failure, provider failure, and downstream-job failure.

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
