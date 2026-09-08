# Billing Event Consumers

Event consumers are inbound adapters that react to domain or integration events.

This is still the physical `billing/` path; `invoicing` is the product name we want to expose publicly.

Current consumer:

- `payment_captured_consumer.rb`

## Rule

- Consumers translate the event into an application command or query.
