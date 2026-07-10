---
id: ci-cd-and-environments
aliases: []
tags:
  - work-items
  - ci
  - cd
  - environments
  - qa
  - staging
  - prod
  - docker
depends_on:
  - bootstrap-and-environment
  - testing-foundation
  - frontend-toolchain
order: 3
phase: work-items
status: draft
title: CI/CD and Environments
---

# CI/CD and Environments

## Goal

- [ ] Define the delivery pipeline, the environment-specific Docker image strategy, and the test gates that control promotion from local development to QA, staging, and production.

## Scope

- Multi-stage Docker image strategy shared across environments.
- Environment-specific execution flow for linting, automated tests, and manual QA.
- Promotion rules from CI to QA to staging to production.
- Explicit handoff points for exploratory QA findings and regression fixes.
- Separation of caches and runtime artifacts by environment and purpose.

## Implementation Tasks

### Environment Model

- [ ] Confirm the environment map: `local/dev`, `ci/test`, `qa`, `staging`, and `prod`.
- [ ] Confirm the image stages: `dev`, `test`, `qa`, `staging`, and `prod`.
- [ ] Document which artifacts are immutable and promoted between environments.

### CI Gates

- [ ] Define the earliest lint gate and keep it single-pass.
- [ ] Define the automated test bundle for push and pull request events.
- [ ] Define which tests are required before a QA deploy.

### QA Flow

- [ ] Define the automated QA deploy step.
- [ ] Define the manual QA signoff step.
- [ ] Define the exploratory failure handback path to development.

### Staging Flow

- [ ] Define the promotion rule from QA to staging.
- [ ] Define the staging smoke checks that run after deploy.
- [ ] Define the release-readiness criterion for staging.

### Production Flow

- [ ] Define the production promotion rule from staging.
- [ ] Define the minimal production runtime image constraints.
- [ ] Define the post-deploy smoke validation for production.

### Artifact and Cache Rules

- [ ] Define how compiled assets are rebuilt for each promoted artifact.
- [ ] Define which caches stay environment-scoped.
- [ ] Define which tooling must never reach the `prod` image.

## Environment Map

| Environment | Primary Purpose | Image Stage | Notes |
| --- | --- | --- | --- |
| `local/dev` | Developer loop and hot reload | `dev` | Uses live reload and local editing flow. |
| `ci/test` | Automated validation on push/PR | `test` | Runs the fast automated suite. |
| `qa` | Controlled automated deploy and manual QA | `qa` | Receives promoted artifacts after CI passes. |
| `staging` | Final manual signoff before production | `staging` | Receives the QA-approved artifact for release validation. |
| `prod` | Production runtime | `prod` | Minimal runtime image, no test or dev tooling. |

## Pipeline Matrix

### Local Development

- `standardrb` or equivalent linting may be run manually or via a fast pre-push hook.
- `RSpec` unit/request coverage runs as needed by the developer.
- Full smoke, acceptance, and mutation testing remain optional locally unless explicitly requested.

### Branch Push and Pull Request

- Run linting once at the earliest CI stage.
- Run fast automated test coverage: unit, request, and selected integration tests.
- Use the `test` image stage for deterministic test execution.
- Avoid re-running the same lint step in later stages unless a new artifact requires it.

### QA Deployment

- Deploy the CI-approved artifact to `qa`.
- Run post-deploy smoke tests automatically.
- Run selected acceptance scenarios automatically when practical.
- Require manual QA validation after the automated gates pass.
- Document exploratory findings, even when the failure is outside the scripted suite.

### Staging Deployment

- Promote only after QA signs off manually.
- Use the same build artifact that passed QA, or an immutable promoted digest from the same commit.
- Run a smaller post-deploy smoke suite if needed.
- Treat staging as the final release readiness environment before production.

### Production Deployment

- Promote only the staging-approved artifact.
- Keep the runtime image minimal.
- Skip test and dev dependencies in the final image.
- Prefer smoke-only post-deploy validation.

## Artifact Rules

- Never rely on stale compiled assets.
- Build assets from the current commit for each promoted artifact.
- Keep test and runtime caches separate by purpose and environment.
- Do not carry `node_modules`, test gems, or dev-only tooling into `prod`.
- Use Docker multistage builds to keep each runtime image minimal.

## QA Handback

- If QA finds a defect, capture the scenario and evidence in the project tracker.
- Move the ticket back to the development state with the documented failure.
- Add or update automated coverage before re-promoting the fix.
- Re-run the relevant automated checks before QA revalidation.

## Validation

- [ ] The pipeline map is explicit for each environment and image stage.
- [ ] Linting is defined as a single-pass early gate.
- [ ] QA has a documented automated deploy plus manual signoff path.
- [ ] Staging has a documented promotion rule from QA.
- [ ] Production has a documented minimal-image and smoke-only validation policy.
- [ ] QA handback documents how defects return to development.

## Related Docs

- `docs/work-items/001-bootstrap-and-environment.md`
- `docs/work-items/002-testing-foundation.md`
- `docs/work-items/004-frontend-toolchain.md`
- `docs/overview.md`

## Notes

- Keep `qa` and `staging` separate on purpose: QA validates the automated pipeline and exploratory findings, staging validates manual signoff on the promoted release artifact.
- Linting should run once in the earliest sensible pipeline stage, not be repeated at every hop.
- Automatic test execution should happen when the pipeline reaches its intended stage, not manually in ad hoc commands.
