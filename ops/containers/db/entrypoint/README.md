# MySQL Entrypoint Assets

This directory contains files mounted into MySQL's `docker-entrypoint-initdb.d` directory.

## Layout

- `initdb.d/` - Scripts executed on first database startup.

## Notes

- Prefer shell scripts when initialization needs environment variables.
