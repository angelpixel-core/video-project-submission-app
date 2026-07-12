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

- [ ] Define the Render-based infrastructure requirements for `qa`, `staging`, and `prod` so the deployment target is explicit before implementation continues.

## Scope

- Render service map for `qa`, `staging`, and `prod`.
- PostgreSQL deployment strategy on Render.
- Custom domains, TLS, and DNS requirements.
- Environment variables, secrets, and resource sizing.
- Capacity and cost drivers for the deployment target.
- GitHub Actions handoff into Render.

## Render Service Map

### Render Runtime Environments

| Environment | Web Service | Database | Domain | Notes |
| --- | --- | --- | --- | --- |
| `qa` | `video-project-submission-app-qa` | Managed PostgreSQL | `qa.<placeholder-domain>` | Used for automated deploy + QA validation. |
| `staging` | `video-project-submission-app-staging` | Managed PostgreSQL | `staging.<placeholder-domain>` | Used for release candidate validation. |
| `prod` | `video-project-submission-app-prod` | Managed PostgreSQL | `<placeholder-domain>` | Human-approved release target. |

### Local Development Context

| Environment | Web Service | Database | Domain | Notes |
| --- | --- | --- | --- | --- |
| `dev` | Local Rails web service | Local MySQL | `dev.lvh.me` | Developer loop only; not a Render environment. |
| `test` | Local Rails web service | Local MySQL | `test.lvh.me` | Automated test context; not a Render environment. |

### Render vs Local Boundary

- Render runtime environments are only `qa`, `staging`, and `prod`.
- Local `dev` and `test` are separate contexts for developer flow and automated checks.
- Local `dev/test` keep MySQL because that is the current baseline for development and CI.
- `dev.lvh.me` and `test.lvh.me` are local-only domains and do not imply a Render deployment target.

### Naming Convention

- Use long, explicit service names for Render to keep the environment role obvious in multi-environment operations.
- Keep local `dev` and `test` as separate context rows so the full runtime picture stays readable without implying they are Render targets.
- Use `lvh.me` for local subdomains because it resolves to `127.0.0.1` and supports host-based local routing without extra host file entries.

### Web Service by Environment

| Environment | Web Service | Purpose | Deployment Source | Notes |
| --- | --- | --- | --- | --- |
| `qa` | `video-project-submission-app-qa` | Automated deploy + QA validation | GitHub Actions promotion from `work-items/*` -> `development` | Public Render environment. |
| `staging` | `video-project-submission-app-staging` | Release candidate validation | Promoted from QA after approval | Public Render environment. |
| `prod` | `video-project-submission-app-prod` | Production runtime | Manual release promotion from staging | Public Render environment. |

### Manual Verification

- I can explain what runs in the `qa` web service.
- I can explain what runs in the `staging` web service.
- I can explain what runs in the `prod` web service.
- I can point to the branch or promotion path that feeds `qa`, `staging`, and `prod`.
- I can distinguish Render runtime environments from local `dev/test` contexts.

## Affected Docs

- `docs/decisions/05-render-infrastructure-target.md`
- `docs/decisions/06-database-engine-matrix.md`
- `docs/decisions/07-infrastructure-as-code-strategy.md`
- `docs/decisions/index.md`
- `docs/overview.md`

## Affected Ops

- Render dashboard / workspace
- Render web services for `qa`, `staging`, and `prod`
- Render managed PostgreSQL services
- Render persistent storage / backups
- DNS provider / registrar
- GitHub Actions deployment workflow

## Checklist

- [x] Define the Render service map for `qa`, `staging`, and `prod`.
- [x] Define the `qa` web service.
- [x] Define the `staging` web service.
- [x] Define the `prod` web service.
- [ ] Define the deployment source for `qa`, `staging`, and `prod`.
- [x] Distinguish Render runtime environments from local `dev/test` contexts.
- [ ] Choose the PostgreSQL deployment mode on Render.
- [ ] Define the custom domains and TLS requirements for each environment.
- [ ] Define the app secrets and database variables per environment.
- [ ] Define persistent storage and backup expectations for PostgreSQL.
- [ ] Define capacity assumptions for web concurrency, database size, and request volume.
- [ ] Define the deployment entry point from GitHub Actions into Render.

## Validation

- [x] I can point to the exact web service and database service for each environment without ambiguity.
- [x] I can explain what runs in the `qa` web service.
- [x] I can explain what runs in the `staging` web service.
- [x] I can explain what runs in the `prod` web service.
- [ ] I can point to the branch or promotion path that feeds `qa`, `staging`, and `prod`.
- [x] I can distinguish Render runtime environments from local `dev/test` contexts.
- [ ] I can state whether it is one managed database per environment and why that choice was made.
- [ ] I can name the hostname for each environment and confirm who terminates TLS.
- [ ] I can list the required secrets/vars for each environment and where they must live.
- [ ] I can state whether persistence/backups are required and what retention expectation exists.
- [ ] I can estimate initial sizing without guessing or leaving it implicit.
- [ ] I can explain exactly what event or job triggers the deploy promotion.

## Notes

- Prefer separate services for the web runtime and the database.
- Use PostgreSQL on Render for `qa`, `staging`, and `prod` to match the deployment target.
- Keep the document focused on infrastructure requirements, not implementation details.
- Treat Redis as optional until the application actually needs it.
- Use placeholders for domains and secret names when the real values are not yet finalized.
- This work item should stay limited to requirements that unblock the remaining deployment-promotion steps in `docs/work-items/003-ci-cd-and-environments.md`.
