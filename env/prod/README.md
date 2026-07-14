# Production Environment

This directory is reserved for production environment files.

## Layout

- `app/` - Production application runtime variables.
- `db/` - Production database bootstrap variables.
- `stack/` - Production stack variables.

## Notes

- Version `app/core.env` and `stack/compose.env` when they are non-secret.
- Keep `app/db.env` and `db/bootstrap.env` versioned with placeholders when values are not yet final.
- Use `secrets.local.env` files in `app/`, `db/`, and `stack/` for versioned placeholder secret values when needed.
