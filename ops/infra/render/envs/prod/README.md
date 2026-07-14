# Production Environment

`prod` is the final release environment after the merged `main` release commit is tagged.

## Purpose

- Receive the release-tagged artifact from `main`.
- Run the final production deploy.
- Validate the live release with smoke checks.

## Current State

- No live Render state is imported yet.
- No production `import` blocks are defined yet.
- The worker is scaffolded but disabled by default.

## Release Flow

1. QA signs off.
2. `Promote` deploys to staging.
3. Staging passes and creates the release PR.
4. The release PR is approved and merged into `main`.
5. A release tag is created from `main`.
6. Production deploys from the tagged release.

## Notes

- Keep the structure aligned with staging.
- Enable the worker only when prod actually needs it.
