# MySQL Container Assets

This directory contains MySQL-specific initialization assets.

## Layout

- `init/` - Scripts mounted into the MySQL entrypoint initialization directory.

## Notes

- Keep initialization scripts idempotent where possible.
- Use this directory only for database bootstrap concerns.
