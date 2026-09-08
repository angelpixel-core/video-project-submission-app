# Billing Policies

Business policies and decision rules for billing belong here.

The code remains under `billing/` physically, but the public product vocabulary is `invoicing`.

Current policies:

- `invoice_generation_policy.rb`
- `tax_calculation_policy.rb`

## Rule

- Policies stay pure and do not call infrastructure.
