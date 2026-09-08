# Billing Aggregates

Aggregate roots and lifecycle behavior for billing belong here.

Keep this under the physical `billing/` tree; `invoicing` is the target product vocabulary.

Current aggregate:

- `invoice.rb`

## Rule

- Aggregates own invariants, state transitions, and domain event emission.
