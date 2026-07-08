# Example Environment

This directory contains reference environment files that can be copied into other environments.

## Layout

- `app/` - Example application runtime variables.
- `db/` - Example database bootstrap variables.
- `stack/` - Example stack/build variables.

## Notes

- Treat these values as non-secret defaults.
- Use this directory as the template for new environment folders.
- `stack/compose.env` must define `STACK_ENV=example` for compose interpolation.
