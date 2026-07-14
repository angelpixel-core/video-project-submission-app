---
id: infrastructure-as-code-strategy
title: Infrastructure as Code Strategy
phase: decisions
order: 7
aliases: []
tags:
  - decisions
  - infrastructure
  - terraform
  - render
  - ci-cd
---

# Infrastructure as Code Strategy

## Decision

Use Terraform directly to provision and manage the Render infrastructure for the application.

## Rationale

- Render has a Terraform provider, so Terraform can model the platform resources directly.
- Using Terraform avoids introducing Pulumi as an extra abstraction layer on top of Terraform.
- Terraform is the more standard and portable choice for infrastructure review and future hiring/maintenance.
- The infrastructure layer should remain explicit and reproducible alongside the application code.

## Scope

- Render services for `qa`, `staging`, and `prod`.
- Managed PostgreSQL services and related environment variables.
- Domain, TLS, and resource sizing configuration.
- Future Redis or worker services if the app needs them.

## CI/CD Placement

- Infrastructure changes should live in a dedicated `ops/infra/` tree or equivalent.
- GitHub Actions should run a separate infra pipeline for `fmt`, `validate`, and `plan` on pull requests.
- `apply` should be manual or approval-gated.
- Infrastructure changes should not be mixed into feature work-item branches unless the change is explicitly about infrastructure.

## Notes

- Terraform is the baseline choice here because it keeps the provider layer one step closer to the platform.
- Pulumi remains a possible future option, but not the default for this repository.
