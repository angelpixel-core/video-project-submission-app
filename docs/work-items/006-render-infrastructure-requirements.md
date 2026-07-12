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
- Render account, workspace, and access bootstrap.
- PostgreSQL deployment strategy on Render.
- Custom domains, TLS, and DNS requirements.
- Environment variables, secrets, and resource sizing.
- Capacity and cost drivers for the deployment target.
- GitHub Actions handoff into Render.

## Access Bootstrap

### Render Onboarding Choices

| Item | Selected Value | Manual Verification |
| --- | --- | --- |
| Workspace name | `video-project-submission-app` | I can identify the workspace by the repo name without ambiguity. |
| Workspace type | `Work` | I can confirm the workspace is for a real project, not a personal sandbox. |
| Team size | `Just me` | I can confirm the workspace is currently scoped to a solo maintainer. |
| What are you building? | `Website / landing page` | I can treat the app as a customer-facing web application in Render onboarding language. |
| Primary capability | `Developer velocity` | I can justify that fast deploy feedback matters more than advanced platform capabilities at this stage. |
| Secondary capability | `Security` | I can keep access control and credentials management explicit from the start. |

### Web Service Bootstrap Snapshot

| Field | Selected Value | Manual Verification |
| --- | --- | --- |
| Source code | `angelpixel-core / video-project-submission-app` | I can confirm the service is connected to the correct repository. |
| Service name | `video-project-submission-app` | I can see the current service name in Render. |
| Language | `Ruby` | I can confirm Render is treating the app as a Ruby runtime. |
| Branch | `development` | I can confirm the service deploys from the `development` branch. |
| Region | `Oregon (US West)` | I can confirm the Render region for this service. |
| Build command | `bundle install && npm ci && bundle exec vite build` | I can confirm the build step installs Ruby and Node dependencies and compiles assets. |
| Start command | `bundle exec puma -C config/puma.rb` | I can confirm the service starts through Puma. |
| Env var | `RAILS_LOG_TO_STDOUT=true` | I can confirm Rails logs are routed to stdout. |
| Env var | `RAILS_MASTER_KEY=<secret>` | I can confirm the Rails master key is configured as a secret. |
| Env var | `DATABASE_URL=<secret>` | I can confirm the service reads its DB connection from Render secrets. |

- If this service is the `qa` runtime, prefer renaming it to `video-project-submission-app-qa` before the first deploy so the service role is explicit.

### Render Workspace

| Item | Manual Verification |
| --- | --- |
| Create or confirm the Render account/workspace. | I can sign in to Render and see the workspace that will host the app. |
| Record the Render workspace URL and owner/team name. | I can point to the exact Render workspace URL and the responsible team/owner. |
| Create a Render API token for automation. | I can identify the token name and where it is stored without exposing the secret value. |
| Confirm the onboarding responses are recorded for the workspace. | I can point to the saved workspace name and selected onboarding options. |

### URLs and External Access

| Item | Manual Verification |
| --- | --- |
| Define the public URLs for `qa`, `staging`, and `prod`. | I can name the hostname for each public environment. |
| Define the DNS registrar/provider access path. | I can say who controls DNS and how records will be updated. |
| Define the GitHub Actions secret names needed for deployment. | I can list the secret names required for Render promotion and deploys. |

### Custom Domains and TLS

| Environment | Public Hostname | TLS Termination | Notes |
| --- | --- | --- | --- |
| `qa` | `qa.<placeholder-domain>` | Render-managed certificate | Used for automated deploy and QA validation. |
| `staging` | `staging.<placeholder-domain>` | Render-managed certificate | Used for release candidate validation. |
| `prod` | `<placeholder-domain>` | Render-managed certificate | Human-approved release target. |

- Render should terminate TLS for each public hostname.
- Keep the hostname values as placeholders until the real DNS zone is finalized.
- DNS records should point the public hostname to the matching Render service target.

### Keys and Tokens

| Item | Manual Verification |
| --- | --- |
| Keep Render access credentials out of git. | I know where the token lives and can rotate it without a repo change. |
| Keep DNS provider credentials out of git. | I know which secret store or account holds DNS access. |
| Keep deployment tokens separate from human login credentials. | I can distinguish the automation token from personal account access. |

### PostgreSQL Bootstrap Snapshot

| Item | Selected Value | Manual Verification |
| --- | --- | --- |
| Database name | `video_project_submission_app_qa_db` | I can identify the QA database by a stable environment-specific name. |
| Database user | `video_project_submission_app_qa` | I can identify the dedicated DB user for the QA environment. |
| Region | `Oregon (US West)` | I can confirm the database lives in the same region as the app service. |
| PostgreSQL version | `18` | I can confirm the version selected in Render. |
| Plan | `Free` | I can confirm the initial plan choice for the bootstrap phase. |
| Storage | `1 GB` | I can confirm the initial storage allocation. |
| Storage autoscaling | `Disabled` | I can confirm autoscaling is off for the bootstrap database. |
| High availability | `Disabled` | I can confirm HA is off for the bootstrap database. |
| Inbound IP policy | `0.0.0.0/0` visible in the UI | I can confirm the current network exposure setting that Render shows for this database. |

### DATABASE_URL Source

- Use the Render **Internal Database URL** for the web service `DATABASE_URL` environment variable.
- Do not use the external URL for the app runtime unless you have a specific off-platform client that needs it.
- Treat the password and full connection string as secrets and keep them out of git.

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

### PostgreSQL Deployment Mode

Use one Render-managed PostgreSQL database per runtime environment.

| Environment | Database Mode | Notes |
| --- | --- | --- |
| `qa` | Managed PostgreSQL service | Dedicated database for QA validation. |
| `staging` | Managed PostgreSQL service | Dedicated database for release candidate validation. |
| `prod` | Managed PostgreSQL service | Dedicated production database. |

### Rationale

- Keep database boundaries aligned with environment boundaries.
- Avoid sharing state between QA, staging, and production.
- Use the native managed PostgreSQL product offered by Render.
- Keep local `dev/test` on MySQL, since those contexts are already defined outside Render.

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

- Render account / workspace
- Render dashboard / workspace
- Render web services for `qa`, `staging`, and `prod`
- Render managed PostgreSQL services
- Render persistent storage / backups
- DNS provider / registrar
- GitHub Actions deployment workflow
- Render API token / automation credentials
- DNS provider API token / access credentials

## Checklist

- [ ] Create or confirm the Render account/workspace.
- [ ] Record the Render workspace URL and owner/team name.
- [ ] Create a Render API token for automation.
- [x] Record the Render onboarding choices for the workspace.
- [x] Record the current Render web service bootstrap snapshot.
- [x] Record the PostgreSQL bootstrap snapshot for the QA database.
- [ ] Define the public URLs for `qa`, `staging`, and `prod`.
- [ ] Define the DNS registrar/provider access path.
- [ ] Define the GitHub Actions secret names needed for deployment.
- [ ] Keep Render access credentials out of git.
- [ ] Keep DNS provider credentials out of git.
- [ ] Keep deployment tokens separate from human login credentials.
- [x] Define the Render service map for `qa`, `staging`, and `prod`.
- [x] Define the `qa` web service.
- [x] Define the `staging` web service.
- [x] Define the `prod` web service.
- [x] Define the deployment source for `qa`, `staging`, and `prod`.
- [x] Distinguish Render runtime environments from local `dev/test` contexts.
- [x] Choose the PostgreSQL deployment mode on Render.
- [x] Define the custom domains and TLS requirements for each environment.
- [ ] Define the app secrets and database variables per environment.
- [ ] Define persistent storage and backup expectations for PostgreSQL.
- [ ] Define capacity assumptions for web concurrency, database size, and request volume.
- [ ] Define the deployment entry point from GitHub Actions into Render.

## Validation

- [ ] I can sign in to Render and see the workspace that will host the app.
- [ ] I can point to the exact Render workspace URL and the responsible team/owner.
- [ ] I can identify the token name and where it is stored without exposing the secret value.
- [x] I can point to the saved workspace name and selected onboarding options.
- [x] I can point to the current Render web service bootstrap snapshot.
- [ ] I can name the hostname for each public environment.
- [ ] I can say who controls DNS and how records will be updated.
- [ ] I can list the secret names required for Render promotion and deploys.
- [ ] I know where the Render token lives and can rotate it without a repo change.
- [ ] I know which secret store or account holds DNS access.
- [ ] I can distinguish the automation token from personal account access.
- [x] I can point to the exact web service and database service for each environment without ambiguity.
- [x] I can explain what runs in the `qa` web service.
- [x] I can explain what runs in the `staging` web service.
- [x] I can explain what runs in the `prod` web service.
- [x] I can point to the branch or promotion path that feeds `qa`, `staging`, and `prod`.
- [x] I can distinguish Render runtime environments from local `dev/test` contexts.
- [x] I can state whether it is one managed database per environment and why that choice was made.
- [x] I can point to the saved QA PostgreSQL bootstrap snapshot.
- [x] I can identify the Internal Database URL as the source for `DATABASE_URL`.
- [x] I can name the hostname for each environment and confirm who terminates TLS.
- [ ] I can list the required secrets/vars for each environment and where they must live.
- [ ] I can state whether persistence/backups are required and what retention expectation exists.
- [ ] I can estimate initial sizing without guessing or leaving it implicit.
- [x] I can explain exactly what event or job triggers the deploy promotion.

## Notes

- Prefer separate services for the web runtime and the database.
- Use PostgreSQL on Render for `qa`, `staging`, and `prod` to match the deployment target.
- Keep the document focused on infrastructure requirements, not implementation details.
- Treat Redis as optional until the application actually needs it.
- Use placeholders for domains and secret names when the real values are not yet finalized.
- This work item should stay limited to requirements that unblock the remaining deployment-promotion steps in `docs/work-items/003-ci-cd-and-environments.md`.
