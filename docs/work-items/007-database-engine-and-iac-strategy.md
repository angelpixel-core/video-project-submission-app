---
id: database-engine-and-iac-strategy
aliases: []
tags:
  - work-items
  - database
  - mysql
  - postgresql
  - terraform
  - render
depends_on:
  - render-infrastructure-requirements
  - ssh-authentication-and-commit-signing
order: 7
phase: work-items
status: draft
title: Database Engine and IaC Strategy
---

# Database Engine and IaC Strategy

## Goal

- [ ] Define and implement the database engine matrix and Terraform-based infrastructure strategy for the Render deployment target.

## Scope

- MySQL for `dev` and `test`.
- PostgreSQL for `qa`, `staging`, and `prod`.
- Rails app compatibility for PostgreSQL on Render.
- Rails database adapter configuration per environment.
- Schema format choice and portability guardrails.
- Terraform-based provisioning for Render resources.

## Affected Docs

- `docs/decisions/05-render-infrastructure-target.md`
- `docs/decisions/06-database-engine-matrix.md`
- `docs/decisions/07-infrastructure-as-code-strategy.md`
- `docs/decisions/index.md`
- `docs/work-items/006-render-infrastructure-requirements.md`
- `docs/overview.md`

## Affected Ops

- `Gemfile`
- `Gemfile.lock`
- `config/database.yml`
- `db/schema.rb`
- `ops/infra/terraform/`
- GitHub Actions infra workflow

## Checklist

- [ ] Document the MySQL-to-PostgreSQL environment matrix.
- [ ] Confirm `schema.rb` remains the default schema format.
- [ ] Update Rails database configuration for PostgreSQL in `qa`, `staging`, and `prod`.
- [ ] Add the production PostgreSQL driver dependency.
- [ ] Define the Terraform layout for Render provisioning.
- [ ] Define the infra pipeline triggers for `fmt`, `validate`, `plan`, and `apply`.
- [ ] Define the provisioning inputs for domain, TLS, app service, and database resources.

## Validation

- [ ] The environment matrix is explicit and documented.
- [ ] The Terraform strategy is explicit and documented.
- [ ] The Rails database configuration supports all runtime environments.
- [ ] The Rails app can connect to PostgreSQL in Render without affecting local MySQL.
- [ ] The infra pipeline can be run independently of app feature work.

## Notes

- Keep the matrix conservative while the project stays on `schema.rb`.
- Prefer separate pipelines for app code and infrastructure code.
- Avoid introducing Pulumi as an extra wrapper unless Terraform becomes insufficient.
- This work item closes the loop on the remaining deployment-promotion items in `docs/work-items/003-ci-cd-and-environments.md` by defining the final database-engine and provisioning strategy.
