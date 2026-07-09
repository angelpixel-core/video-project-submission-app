# Development Environment

This directory contains development-only environment files, split by consumer.

## Layout

- `app/` - Application runtime variables.
- `db/` - Database bootstrap variables.
- `stack/` - Compose/build variables.

## Notes

- Keep development values aligned with the local bootstrap work item.
- Do not place unrelated service variables here.
- Local secrets live in `secrets.local.env` files and are ignored by git.
- `stack/compose.env` must define `STACK_ENV=dev` for compose interpolation.
