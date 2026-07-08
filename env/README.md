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

## Notes

- Keep consumer-specific variables in the matching subdirectory.
- Avoid mixing app runtime values with database bootstrap values unless a target explicitly needs both.
- Ignore local secret files named `secrets.local.env`; they are synced separately to external secret stores.
- In `prod/`, `qa/`, and `staging/`, keep `app/db.env` and `db/bootstrap.env` local-only; version the non-secret `app/core.env` and `stack/compose.env` files instead.
