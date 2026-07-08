# Development Stack Variables

This directory contains environment variables used by the local stack orchestration.

## Files

- `compose.env` - Values used by Compose interpolation and build arguments.

## Notes

- Keep stack-level values separate from app and database runtime variables.
- `STACK_ENV=dev` should be defined here.
