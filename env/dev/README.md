# Development Environment

This directory contains development-only environment files, split by consumer.

## Layout

- `app/` - Application runtime variables.
- `db/` - Database bootstrap variables.
- `stack/` - Compose/build variables.

## Notes

- Keep development values aligned with the local bootstrap work item.
- Do not place unrelated service variables here.
- `secrets.local.env` files hold versioned placeholders for secret values when needed.
- `stack/compose.env` must define `STACK_ENV=dev` for compose interpolation.
