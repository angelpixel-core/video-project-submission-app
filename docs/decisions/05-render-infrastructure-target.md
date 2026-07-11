---
id: render-infrastructure-target
title: Render Infrastructure Target
phase: decisions
order: 5
aliases: []
tags:
  - decisions
  - render
  - infrastructure
  - deployment
  - mysql
  - rails
---

# Render Infrastructure Target

## Decision

Use Render as the deployment platform for the Rails application runtime and its promotion environments.

## Scope

- Rails web runtime for `qa`, `staging`, and `prod`.
- Render-managed deployment flow triggered from GitHub Actions.
- Custom domain and TLS termination handled by Render.
- The runtime environments on Render use PostgreSQL, because Render provides native managed PostgreSQL but not native managed MySQL.
- Redis remains optional for future cache or queue needs; the current baseline does not require it.

## Infrastructure Requirements

### Per Environment

| Environment | App Service | Database | Domain | Notes |
| --- | --- | --- | --- | --- |
| `qa` | Rails web service | Managed PostgreSQL service | `qa.<placeholder-domain>` | Used for automated deploy + QA validation. |
| `staging` | Rails web service | Managed PostgreSQL service | `staging.<placeholder-domain>` | Used for release candidate validation. |
| `prod` | Rails web service | Managed PostgreSQL service | `<placeholder-domain>` | Human-approved release target. |

### Platform Resources

- One Render web service per environment.
- One managed PostgreSQL service per environment.
- Render environment variables for app secrets and database credentials.
- DNS records for each environment hostname.
- TLS certificates for each public hostname.
- Optional Redis only if the app later needs shared cache, pub/sub, or job processing that is not handled by the database-backed stack.

## Rationale

- Render is a strong fit for Dockerized Rails deployments with low operational overhead.
- Keeping the web runtime and database as separate services preserves observability and clean failure boundaries.
- A managed PostgreSQL service keeps the runtime environments aligned with the target platform and avoids self-managing MySQL on Render.
- The deployment model fits the existing GitHub Actions promotion flow and pairs cleanly with Terraform for reproducible provisioning.

## Notes

- Costs and capacity should be modeled per service and per environment.
- The app's request capacity is bounded by the Rails process size, PostgreSQL latency, and the selected Render instance sizes.
- Revisit the database hosting choice if the operational burden of PostgreSQL on Render becomes too high.
