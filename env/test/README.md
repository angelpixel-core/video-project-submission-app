# Test Environment

This directory is reserved for test environment files.

## Layout

- `app/` - Test application runtime variables.
- `db/` - Test database bootstrap variables.
- `stack/` - Test stack variables.

## Notes

- Add test-specific values only when test orchestration is defined.
- Test env files can be versioned when they are non-secret CI configuration.
- `stack/compose.env` must define `STACK_ENV=test` for compose interpolation.
- Use `secrets.local.env` files in `app/`, `db/`, and `stack/` for versioned placeholder secret values when needed.
