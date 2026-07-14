# Environment Files

This directory stores environment-specific configuration for local development, testing, production, examples, and future environments.

## Layout

- `dev/` - Development values.
- `test/` - Test values.
- `qa/` - QA values.
- `staging/` - Staging values.
- `prod/` - Production values.
- `example/` - Non-secret reference values and templates.

Each environment is split by consumer:

- `app/` - Application runtime variables.
- `db/` - Database bootstrap variables.
- `stack/` - Stack-level compose/build variables.
- `secrets.local.env` - Versioned placeholder secrets file in each consumer directory when needed.

## Notes

- Keep consumer-specific variables in the matching subdirectory.
- Avoid mixing app runtime values with database bootstrap values unless a target explicitly needs both.
- Use `secrets.local.env` files for versioned placeholders when a value is not ready yet.
- In `prod/`, `qa/`, and `staging/`, version the environment files with placeholders and fill the live values manually in Render or the local secret store.
- When a Render environment file is checked into git, keep secrets and live connection strings as placeholders only.
