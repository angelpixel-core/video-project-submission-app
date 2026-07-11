---
id: render-infrastructure-requirements
aliases: []
tags:
  - work-items
  - render
  - infrastructure
  - deployment
  - postgresql
  - rails
depends_on:
  - ci-cd-and-environments
  - ssh-authentication-and-commit-signing
order: 6
phase: work-items
status: draft
title: Render Infrastructure Requirements
---

# Render Infrastructure Requirements

## Goal

- [ ] Define and provision the Render-based infrastructure requirements for the Rails app runtime environments.

## Scope

- Render service map for `qa`, `staging`, and `prod`.
- PostgreSQL deployment strategy on Render.
- Custom domains, TLS, and DNS requirements.
- Environment variables, secrets, and resource sizing.
- Capacity and cost drivers for the deployment target.

## Affected Docs

- `docs/decisions/05-render-infrastructure-target.md`
- `docs/decisions/06-database-engine-matrix.md`
- `docs/decisions/07-infrastructure-as-code-strategy.md`
- `docs/decisions/index.md`
- `docs/overview.md`

## Affected Ops

- Render dashboard / workspace
- Render web services
- Render managed PostgreSQL services
- Render persistent storage
- DNS provider / registrar

## Checklist

- [ ] Define the Render service map for `qa`, `staging`, and `prod`.
- [ ] Choose the PostgreSQL deployment mode on Render and document the tradeoff.
- [ ] Define the custom domains and TLS requirements for each environment.
- [ ] Define the app secrets and database variables per environment.
- [ ] Define persistent storage and backup expectations for PostgreSQL.
- [ ] Define capacity assumptions for web concurrency, database size, and request volume.
- [ ] Define the deployment entry point from GitHub Actions into Render.

## Validation

- [ ] The Render service map exists for every runtime environment.
- [ ] The database strategy is explicit and documented.
- [ ] Each public environment has a host and TLS plan.
- [ ] The infrastructure requirements are sufficient to estimate cost and capacity.

## Notes

- Prefer separate services for the web runtime and the database.
- Treat Redis as optional until the application actually needs it.
- Keep the document focused on infrastructure requirements, not frontend or Rails feature work.
- This work item unlocks the remaining deployment-promotion steps in `docs/work-items/003-ci-cd-and-environments.md` by defining the Render runtime target.
