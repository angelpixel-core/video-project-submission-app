# Development Database Variables

This directory contains environment variables used by the MySQL bootstrap process in development.

## Files

- `bootstrap.env` - Values consumed by the database container at bootstrap time.
- `secrets.local.env` - Versioned placeholder overrides for sensitive database bootstrap values.

## Notes

- Keep this file focused on database initialization only.
