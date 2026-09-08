# Billing Queries

Queries are billing read use cases.

Keep this folder under the physical `billing/` tree; the product-facing vocabulary is `invoicing`.

Current queries:

- `find_invoice.rb`

## Rule

- Queries fetch and shape billing data without mutating state.
