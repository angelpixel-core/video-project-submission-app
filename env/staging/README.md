# Staging Environment

This directory is reserved for staging environment files.

## Layout

- `app/` - Staging application runtime variables.
- `db/` - Staging database bootstrap variables.
- `stack/` - Staging stack variables.

## Notes

- Version `app/core.env` and `stack/compose.env` when they are non-secret.
- Keep `app/db.env` and `db/bootstrap.env` versioned with placeholders when values are not yet final.
- Use `secrets.local.env` files in `app/`, `db/`, and `stack/` for versioned placeholder secret values when needed.
