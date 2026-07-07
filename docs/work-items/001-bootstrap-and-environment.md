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
- Database initialization scripts.
- Rails schema output using `schema.rb`.
- Environment templates separated by stage.

## Out of Scope

- Redis.
- Faktory.
- Redpanda.
- Prometheus.
- OpenTelemetry Collector.
- Tempo.
- Grafana.

## Affected Docs

- `docs/sprints/00-foundation/03-data-model.md`
- `docs/sprints/00-foundation/06-quality-and-performance.md`
- `docs/decisions/02-rails-schema-format.md`

## Affected Ops

- `ops/compose/compose.yml`
- `ops/containers/app/Dockerfile`
- `ops/containers/app/entrypoint.sh`
- `ops/containers/mysql/init/001-bootstrap.sql`
- `env/example/app.env`
- `env/example/compose.env`
- `env/example/db.env`

## Checklist

- [ ] Create or confirm the Rails app baseline.
- [ ] Configure Ruby dependencies.
- [ ] Add jQuery support.
- [ ] Add Bootstrap support.
- [ ] Add a Dockerfile for the app.
- [ ] Add `compose.yml` for the app and MySQL under `ops/compose/`.
- [ ] Use a minimal MySQL image suitable for local development.
- [ ] Add database initialization scripts under `ops/containers/mysql/init/`.
- [ ] Initialize the database and application users through the init scripts.
- [ ] Grant the required MySQL privileges for local development.
- [ ] Keep environment templates under `env/example/`.
- [ ] Configure Rails to use `schema.rb`.
- [ ] Inject `RUBY_VERSION` from environment variables instead of hardcoding it in the Dockerfile.

## Validation

- [ ] `docker compose --env-file env/example/compose.env -f ops/compose/compose.yml up --build` starts the database and app services.
- [ ] MySQL starts via Compose.
- [ ] The Rails app can connect to the database.
- [ ] Schema dumps are generated as `schema.rb`.

## Notes

- Keep the setup minimal so later work items can build on it without rework.
- If MySQL-specific SQL features are not required, prefer `schema.rb` over `structure.sql`.
- The current bootstrap scope only covers the database and app boundary needed for the Rails baseline.
- `RUBY_VERSION` should come from the environment and be shared across `.tool-versions`, compose, and Docker build args.

## Related Docs

- `docs/overview.md`
- `docs/sprints/00-foundation/03-data-model.md`
- `docs/sprints/00-foundation/06-quality-and-performance.md`
- `docs/decisions/02-rails-schema-format.md`

## Related Sections

- `docs/sprints/00-foundation/03-data-model.md` -> `## Requirements`
- `docs/sprints/00-foundation/06-quality-and-performance.md` -> `## Stack and UI`
- `docs/sprints/00-foundation/06-quality-and-performance.md` -> `## Performance`
