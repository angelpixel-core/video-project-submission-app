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

## Implementation Plan

- [x] Create the Terraform base files for each environment under `ops/infra/render/envs/{qa,staging,prod}`.
- [x] Create reusable modules under `ops/infra/render/components/{web,worker,postgres,dns}`.
- [ ] Start with `qa` and wire it to the live Render web service and PostgreSQL service.
- [ ] Express QA adoption with Terraform `import` blocks.
- [ ] Keep `staging` and `prod` in the same shape, but without live state yet.
- [ ] Validate with `terraform fmt`, `terraform init -backend=false`, and `terraform plan` for `qa`.

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
- `ops/infra/render/`
- GitHub Actions infra workflow

## Checklist

- [x] Document the MySQL-to-PostgreSQL environment matrix.
  - [x] Keep `dev` and `test` on MySQL and `qa` on PostgreSQL, with staging/prod reserved for future rollout.
- [x] Confirm `schema.rb` remains the default schema format.
  - [x] The schema strategy is already captured in `docs/decisions/02-rails-schema-format.md`.
- [x] Update Rails database configuration for PostgreSQL in `qa`.
  - [x] Add or adjust a QA-specific Rails config so `DATABASE_URL` is consumed in the deployed environment.
- [x] Add the production PostgreSQL driver dependency.
  - [x] `pg` is already present in the production bundle group in `Gemfile`.
- [x] Define the infra layout for Render provisioning.
  - [x] Create a tool-agnostic `ops/infra/render/` tree organized by platform and environment.
  - [x] Add reusable component/module directories for `web`, `worker`, `postgres`, and `dns`.
  - [x] Add environment directories for `qa`, `staging`, and `prod`.
- [x] Define the infra inventory for each environment.
  - [x] Provision one web service, one worker service, and one managed PostgreSQL service per environment.
  - [x] Keep QA and staging workers separate so queue/config boundaries stay isolated.
  - [x] Capture env vars, secrets, hostname, and TLS requirements per environment.
- [x] Define the infra pipeline triggers for `fmt`, `validate`, `plan`, and `apply`.
  - [x] Run `fmt` and `validate` on pull requests that touch `ops/infra/render/**`.
  - [x] Run `plan` for `qa` and `staging` on pull requests that touch `ops/infra/render/**`.
  - [x] Trigger `apply` manually, one environment at a time.
  - [x] Gate `apply` with approval or protected environment rules.
  - [x] Add GitHub Actions wiring for infra-only validation and approval-gated apply.
- [x] Define the adoption path for existing QA Render resources.
  - [x] Document how Terraform will adopt the live QA Render state before staging is introduced.
  - [x] Capture the concrete Render resource names and hostnames when the Terraform stack is introduced.

## Validation 

- [x] The environment matrix is explicit and documented.
- [x] The Terraform strategy is explicit and documented.
- [x] The Rails database configuration supports all runtime environments.
  - [x] QA-specific Rails database config is present and wired through `DATABASE_URL`.
- [x] The Rails app can connect to PostgreSQL in Render without affecting local MySQL.
  - [x] Verified with `curl -fsS https://video-project-submission-app-qa.onrender.com/up/db` after the QA deploy finished.
- [ ] The infra pipeline can be run independently of app feature work.
  - [ ] `ops/infra/render/` exists, and the workflow is in place, but the Terraform config is not created yet.

## Notes

- Keep the matrix conservative while the project stays on `schema.rb`.
- Prefer separate pipelines for app code and infrastructure code.
- Avoid introducing Pulumi as an extra wrapper unless Terraform becomes insufficient.
- Future rollout note: staging and prod follow the same matrix once QA is stable.
- This work item closes the loop on the database-engine and provisioning strategy for QA first.
