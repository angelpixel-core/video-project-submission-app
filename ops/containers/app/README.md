# App Container

This directory contains the application Dockerfile and entrypoint script.

## Files

- `Dockerfile` - Ruby application image definition.
- `entrypoint.sh` - Startup checks and database preparation.

## Notes

- Keep the image aligned with the Ruby version pinned in tooling and compose.
- Keep startup logic minimal and predictable.
