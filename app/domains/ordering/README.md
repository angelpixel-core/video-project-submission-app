# Ordering Route Map

`ordering` es el boundary de lifecycle de órdenes y de la workflow de submission del marketplace.

## Qué hace hoy

- modela el aggregate root `Order`
- administra estados de draft, placed, confirmed, cancelled y completed
- coordina la submission workflow con payment, capacity e invoicing follow-up
- mantiene snapshots de customer, line items y source video
- expone listing y mutaciones de órdenes para el storefront y el backoffice operativo
- shapea la UI del formulario de órdenes a través de `presentation`

## Qué no debería hacer

- resolver identity o workspace lookup
- definir catálogo o visibilidad de offers
- decidir availability/capacity
- ejecutar pagos como boundary primario
- contener presentation de otros dominios
- mezclar workflow de órdenes con fulfillment operativo

## Current Tree

```text
ordering/
  domain/
    aggregates/
      order.rb
    entities/
      customer_snapshot.rb
      line_item.rb
      offering_snapshot.rb
      source_video.rb
    errors/
      invalid_order.rb
      invalid_order_transition.rb
      invalid_source_url.rb
    events/
      order_cancelled_event.rb
      order_completed_event.rb
      order_confirmed_event.rb
      order_drafted_event.rb
      order_event.rb
      order_placed_event.rb
      order_payment_failed_event.rb
    policies/
      order_acceptance_policy.rb
      order_cancellation_policy.rb
      order_completion_policy.rb
      order_placement_policy.rb
    repositories/
      order/
        contract.rb
    value_objects/
      delivery_status.rb
      editing_instructions.rb
      order_id.rb
      order_number.rb
      order_status.rb
      order_total.rb
      payment_status.rb
      production_status.rb
      source_url.rb
  application/
    commands/
      process_submission.rb
    dto/
      submission.rb
    queries/
      listing_query.rb
  adapters/
    persistence/
      order/
        mapper.rb
        order_line_record.rb
        order_record.rb
        repository.rb
        source_video_record.rb
  presentation/
    order_form_presenter.rb
```

## Physical Presentation Layer

- `app/domains/ordering/presentation/order_form_presenter.rb`

## What `presentation` Means Here

`presentation` is the layer that shapes order data for the edge of the app.

- form titles
- field names
- labels and placeholders
- order-specific UI copy

## Current Rules

- `Order` is the aggregate root.
- `ProcessSubmission` is the main submission workflow.
- `ListingQuery` is the public listing query.
- `OrderFormPresenter` belongs to `presentation`, not `domain`.
- `Domain::Policies` decide whether an order can transition.
- `Adapters::Persistence` own database mapping and repositories.
- Completion requires a confirmed order, completed production, delivered output, and no payment-flow blocker.
- Legacy `pending` and `in_progress` states map to canonical `placed` and `confirmed` states; `reopen` remains a legacy fulfillment action and resets operational checkpoints.

## Workflow Boundaries

- `validate_submission` fails fast before side effects.
- `capture_or_confirm_payment` delegates payment execution to `payments`.
- `success_handling` runs only after the payment checkpoint.
- `enqueue_follow_up_work` starts invoice and notification follow-up.

## Public Contract

The current public contract for `ordering` is:

- `Ordering::Application::Commands::ProcessSubmission`
- `Ordering::Application::Queries::ListingQuery`
- `Ordering::Presentation::OrderFormPresenter`
- `Ordering::Domain::Repositories::Order::Contract`

## Result Contract

`Ordering::Application::Commands::ProcessSubmission` always returns a `Core::Result`.

### Success

Successful submissions return `Core::Result::Success` with:

```ruby
{
  submission:,
  order:,
  payment:,
  reservation:
}
```

The `payment` has passed the success checkpoint, the `reservation` has been committed, and follow-up dependencies have been invoked.

### Failure

Failed submissions return `Core::Result::Failure` with:

```ruby
{
  message: String,
  code: Symbol,
  data: {
    submission:,
    order:,
    # Optional: payment, reservation, line_item, availability
  }
}
```

The failure `data` always carries the submission context when the command has one. Stage-specific details may be added without changing the base contract.

Current failure codes include:

- `:invalid_record` for invalid input, invalid transitions, or checkpoint failures.
- `:unavailable` when an order line cannot be submitted under the availability policy.
- Capacity or payment codes propagated from their respective application contracts.

This contract documents the current behavior. It does not yet introduce a specialized submission result type.

## Plan de refinamiento

### Phase 1: Clarify the boundary

- [ ] Review every file under `ordering/` and separate domain, application, adapters, and presentation concerns.
- [ ] Keep `OrderFormPresenter` out of the domain tree and under `presentation`.
- [ ] Decide whether the current workflow should stay in `ordering` or be split further between `ordering` and `fulfillment`.

### Phase 2: Stabilize the public API

- [ ] Keep the submission workflow contract stable.
- [ ] Keep listing and form presentation contracts stable.
- [ ] Reduce direct knowledge of `payments`, `capacity`, and `billing` to the smallest possible contracts.

### Phase 3: Prepare extraction

- [ ] Move any remaining UI shaping into `presentation`.
- [ ] Make the boundary clearer for shell integration and SDK-style consumption.
- [ ] Add coverage around the public workflow and presenter output before extraction.

### Phase 4: Extract to a standalone app

- [ ] Extract `ordering` as its own Rails app when the contract is stable.
- [ ] Expose order workflow, listing, and form presentation through SDK or HTTP.
- [ ] Keep the storefront focused on orchestration, not internal order mechanics.

## Review Questions

- ¿`Ordering::Presentation::OrderFormPresenter` es el namespace final correcto?
- ¿Qué parte del submit workflow debe seguir en `ordering` y cuál ya pertenece a `fulfillment`?
- ¿Qué contexto del storefront es parte del contract público y qué contexto es solo request metadata?
- ¿El `listing` de órdenes debe seguir viviendo aquí o ser parte de un read model más externo?

## Notes

- Este README es el working contract para el boundary de `ordering`.
- `presentation` existe aquí porque `OrderFormPresenter` shapea la UI del formulario de órdenes.
- `ordering` es el boundary de lifecycle y workflow, no el de availability ni el de catalog.
