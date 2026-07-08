# Repository Defaults

This directory contains defaults for repository creation automation.

## Files

- `create.env` - Versioned repository defaults.
- `create.local.env` - Local overrides, ignored by git.

## Notes

- Keep this configuration independent from app/runtime stack envs.
- Use `REPO_PROVIDER` to switch the provider dispatcher.
