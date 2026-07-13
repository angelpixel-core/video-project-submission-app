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

- [ ] Define and implement the database engine matrix and Terraform-based infrastructure strategy for QA now.
  - [ ] Staging and prod remain future extension points.

## Scope

- MySQL for `dev` and `test`.
- PostgreSQL for `qa`.
- Rails app compatibility for PostgreSQL on Render.
- Rails database adapter configuration for QA.
- Schema format choice and portability guardrails.
- Terraform-based provisioning for Render resources.
- Staging and prod will follow the same pattern when they are activated.

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

- [x] Document the MySQL-to-PostgreSQL environment matrix.
  - [x] Keep `dev` and `test` on MySQL and `qa` on PostgreSQL, with staging/prod reserved for future rollout.
- [x] Confirm `schema.rb` remains the default schema format.
  - [x] The schema strategy is already captured in `docs/decisions/02-rails-schema-format.md`.
- [ ] Update Rails database configuration for PostgreSQL in `qa`.
  - [ ] Add or adjust a QA-specific Rails config so `DATABASE_URL` is consumed in the deployed environment.
- [x] Add the production PostgreSQL driver dependency.
  - [x] `pg` is already present in the production bundle group in `Gemfile`.
- [ ] Define the Terraform layout for Render provisioning.
  - [ ] Create the `ops/infra/terraform/` tree and resource modules.
- [ ] Define the infra pipeline triggers for `fmt`, `validate`, `plan`, and `apply`.
  - [ ] Add GitHub Actions wiring for infra-only validation and approval-gated apply.
- [ ] Define the provisioning inputs for domain, TLS, app service, and database resources.
  - [ ] Capture the concrete Render resource names and hostnames when the Terraform stack is introduced.

## Validation 

- [x] The environment matrix is explicit and documented.
- [x] The Terraform strategy is explicit and documented.
- [ ] The Rails database configuration supports all runtime environments.
  - [ ] QA-specific Rails database config still needs to be added or adjusted.
- [ ] The Rails app can connect to PostgreSQL in Render without affecting local MySQL.
  - [ ] This still needs a QA deploy/config validation run.
- [ ] The infra pipeline can be run independently of app feature work.
  - [ ] `ops/infra/terraform/` and its workflow are not created yet.

## Notes

- Keep the matrix conservative while the project stays on `schema.rb`.
- Prefer separate pipelines for app code and infrastructure code.
- Avoid introducing Pulumi as an extra wrapper unless Terraform becomes insufficient.
- Future rollout note: staging and prod follow the same matrix once QA is stable.
- This work item closes the loop on the database-engine and provisioning strategy for QA first.
