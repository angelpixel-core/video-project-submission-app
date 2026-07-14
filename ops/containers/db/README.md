# Database Container Assets

This directory contains database initialization assets.

## Layout

- `entrypoint/` - Files mounted into the MySQL `docker-entrypoint-initdb.d` directory.

## Notes

- Keep initialization scripts idempotent where possible.
- Use this directory only for database bootstrap concerns.
