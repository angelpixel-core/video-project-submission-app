---
id: data-bootstrap-migrations
aliases: []
tags:
  - work-items
  - data
  - bootstrap
  - identity
  - migrations
  - seeds
  - environments
depends_on:
  - application-boundaries-and-repositories
  - order-domain-and-project-rename
order: 46
phase: work-items
status: draft
title: Data Bootstrap Migrations
---

# Data Bootstrap Migrations

## Goal

- [ ] Introduce a data bootstrap layer for minimum required records so fresh installs can start from an empty schema without relying on demo seeds.

## Scope

- Keep `seeds` for demo/local sample data.
- Add a separate data migration path for minimum required records.
- Bootstrap identity fixtures that the app needs to run, such as default workspace users, memberships, and any fixed reference data.
- Keep bootstrap values environment-driven where deploys need different addresses or identifiers.
- Avoid using data migrations for editable or customer-specific demo content.

## Current Codebase

- `db/seeds.rb` currently creates the default client and PM accounts plus a seed project.
- `Identity::Application::Services::WorkspaceResolver` already depends on default workspace email environment variables.
- `Identity::Domain::Aggregates::User`, `Account`, and `Membership` already exist and are linked through persistence repositories.
- Environment templates now expose `DEFAULT_CLIENT_WORKSPACE_EMAIL` and `DEFAULT_PM_WORKSPACE_EMAIL`.

## Design Notes

- Treat data migrations as required bootstrap, not demo content.
- Keep them idempotent and environment-aware.
- Prefer env vars for environment-specific bootstrap identities.
- Keep seeds small and deterministic for local/demo usage.

## Planned Flow

```text
schema migrate
  -> data bootstrap migrate
    -> create minimum identity records
    -> create minimum reference data
    -> resolve workspace defaults from env
  -> seeds (optional demo/local only)
```

## Implementation Plan

- [ ] Define the data migration location and execution path for minimum bootstrap data.
- [ ] Move required identity bootstrap records out of `db/seeds.rb` into data migrations.
- [ ] Keep optional demo data in `db/seeds.rb`.
- [ ] Make bootstrap values configurable through environment variables where needed.
- [ ] Add specs or smoke checks for the bootstrap path.

## Expected Result

- A fresh database can boot with the minimum required identity data.
- Local/demo seeds remain available without becoming a source of production invariants.
- Environment-specific values can be supplied without hardcoding them into the migration.

## Affected Docs

- `docs/changes/003-payment-confirmation-operational-guide.md`
- `docs/work-items/041-application-boundaries-and-repositories.md`
- `docs/work-items/044-order-domain-and-project-rename.md`

## Affected Ops

- `db/migrate/`
- `db/seeds.rb`
- `db/data_migrate/` or equivalent data migration path
- `env/*/app/core.env`
- `spec/unit/`
- `spec/requests/`

## Checklist

- [ ] Bootstrap data is separated from demo seeds.
- [ ] Minimum identity data is created through data migrations.
- [ ] Workspace defaults are environment-driven.
- [ ] Fresh installs can start without manual bootstrap steps.

## Validation

- [ ] Specs or smoke checks cover the bootstrap flow.
- [ ] Seeds remain deterministic and optional.
- [ ] No environment-specific values are hardcoded into bootstrap data.

## Notes

- The goal is not to seed everything, only the minimum the app cannot function without.
- If a record is editable by users, it usually does not belong in bootstrap data unless it is also a hard dependency.
- `data migrations` should capture required product invariants; `seeds` should capture convenience/demo data.
