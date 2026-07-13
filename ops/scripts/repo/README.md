# Repository Scripts

This directory contains helpers for creating and managing repositories via provider dispatch.

## Files

- `create.sh` - Creates or configures a repository using the selected provider adapter.

## Notes

- Prefer explicit `OWNER` and `NAME` parameters.
- Keep the script non-interactive so it can be used from `make`.
- Use `PRIVATE=true` by default; set `PRIVATE=false` or `PUBLIC=true` for a public repo.
- The script is idempotent: if the repository already exists, it skips creation and ensures the local `origin` remote points at the full repo clone URL.
- `ops/repo/create.env` provides the default repository definition, while `ops/repo/create.local.env` can override it locally.
- `ops/repo/` is a repository provisioning profile, not an application runtime environment.
- `REPO_PROVIDER` controls the provider dispatcher (`github` today, extensible to `gitlab`/`bitbucket`).
