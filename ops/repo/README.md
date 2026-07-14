# Repository Defaults

This directory contains defaults for repository creation automation.

It is not a runtime environment like `dev`, `test`, `qa`, `staging`, or `prod`.
It lives under `ops/` because it is an operational artifact used by repo provisioning scripts.

## Files

- `create.env` - Versioned repository defaults.
- `create.local.env` - Local overrides, ignored by git.

## Notes

- Keep this configuration independent from app/runtime stack envs.
- Use `REPO_PROVIDER` to switch the provider dispatcher.
