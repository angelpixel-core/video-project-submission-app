# Staging Environment

`staging` is the release-readiness environment between QA and production.

## Purpose

- Receive the QA-approved artifact.
- Run staging deploy and smoke checks.
- Gate creation of the `development -> main` release PR.

## Current State

- No live Render state is imported yet.
- No staging `import` blocks are defined yet.
- `Promote` is triggered manually from GitHub Actions.
- No staging worker is defined yet.

## Promotion Flow

1. QA approves the artifact.
2. QA triggers `Promote`.
3. The workflow deploys to staging.
4. Staging smoke checks pass.
5. The system creates or updates the `development -> main` PR.

## Notes

- `prod` is intentionally out of scope for now.
- Keep this environment aligned with QA unless release requirements change.
