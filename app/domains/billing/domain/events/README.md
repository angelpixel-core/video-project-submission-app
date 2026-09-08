# Billing Events

Billing domain events belong here.

This is still the physical `billing/` event tree; `invoicing` is the product-facing name.

Current events:

- `credit_note_issued.rb`
- `invoice_paid.rb`
- `invoice_issued.rb`
- `invoice_issue_failed.rb`

## Rule

- Events describe facts that happened in billing.
