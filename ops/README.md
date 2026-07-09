# Operations Assets

This directory stores operational assets such as compose files, container definitions, and init scripts.

## Layout

- `compose/` - Compose entrypoints for local stack orchestration.
- `containers/` - Container build contexts and runtime scripts.
- `scripts/` - Shell helpers used by the root `Makefile`.

## Notes

- Keep project infrastructure isolated here instead of mixing it into the application root.
