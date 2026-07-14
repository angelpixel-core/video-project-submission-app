# QA Environment

This directory is reserved for QA environment files.

## Layout

- `app/` - QA application runtime values.
- `db/` - QA database bootstrap variables.
- `stack/` - QA stack variables.

## Notes

- Version `app/core.env` and `stack/compose.env` when they are non-secret.
- Keep `app/db.env` and `db/bootstrap.env` versioned with placeholders when values are not yet final.
- Use `secrets.local.env` files in `app/`, `db/`, and `stack/` for versioned placeholder secret values when needed.
