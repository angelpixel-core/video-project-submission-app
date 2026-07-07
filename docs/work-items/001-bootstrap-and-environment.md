---
id: bootstrap-and-environment
title: Bootstrap and Environment
phase: work-items
order: 1
status: draft
depends_on: []
tags:
  - work-items
  - bootstrap
  - docker
  - rails
  - mysql
  - schema
---

# Bootstrap and Environment

## Goal

Set up the application baseline and development environment for the Rails project.

## Scope

- Rails application baseline.
- Ruby and dependency setup.
- jQuery and Bootstrap asset support.
- MySQL service via Docker Compose.
- Database entrypoint scripts for initialization.
- Rails schema output using `schema.rb`.

## Affected Docs

- `docs/sprint-0/03-data-model.md`
- `docs/sprint-0/06-quality-and-performance.md`
- `docs/decisions/02-rails-schema-format.md`

## Checklist

- [ ] Create or confirm the Rails app baseline.
- [ ] Configure Ruby dependencies.
- [ ] Add jQuery support.
- [ ] Add Bootstrap support.
- [ ] Add a Dockerfile for the app.
- [ ] Add `docker-compose` for the app and MySQL.
- [ ] Use a minimal MySQL image suitable for local development.
- [ ] Add database initialization entrypoint scripts.
- [ ] Initialize the database and application users through entrypoint scripts.
- [ ] Grant the required MySQL privileges for local development.
- [ ] Configure Rails to use `schema.rb`.

## Validation

- [ ] The app boots in Docker.
- [ ] MySQL starts via Compose.
- [ ] The Rails app can connect to the database.
- [ ] Schema dumps are generated as `schema.rb`.

## Notes

- Keep the setup minimal so later work items can build on it without rework.
- If MySQL-specific SQL features are not required, prefer `schema.rb` over `structure.sql`.

## Related Docs

- `docs/overview.md`
- `docs/sprint-0/03-data-model.md`
- `docs/sprint-0/06-quality-and-performance.md`
- `docs/decisions/02-rails-schema-format.md`

## Related Sections

- `docs/sprint-0/03-data-model.md` -> `## Requirements`
- `docs/sprint-0/06-quality-and-performance.md` -> `## Stack and UI`
- `docs/sprint-0/06-quality-and-performance.md` -> `## Performance`
