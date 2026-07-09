---
id: bootstrap-and-environment
aliases: []
tags:
  - work-items
  - bootstrap
  - docker
  - rails
  - mysql
  - schema
depends_on: []
order: 1
phase: work-items
status: draft
title: Bootstrap and Environment
---

# Bootstrap and Environment

## Goal

Set up the application baseline and development environment for the Rails project.

## Scope

- Rails application baseline.
- Ruby and dependency setup.
- Frontend asset support is handled by later work items.
- MySQL service via Docker Compose.
- Database initialization scripts.
- Rails schema output using `schema.rb`.
- Environment templates separated by stage and consumer.

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

- `Makefile`
- `ops/scripts/stack.sh`
- `ops/scripts/repo/create.sh`
- `.dockerignore`
- `ops/compose/compose.yml`
- `ops/containers/app/Dockerfile`
- `ops/containers/app/entrypoint.sh`
- `ops/containers/db/entrypoint/initdb.d/001-bootstrap.sh`
- `env/.gitignore`
- `env/dev/app/core.env`
- `env/dev/app/db.env`
- `env/dev/db/bootstrap.env`
- `env/dev/stack/compose.env`
- `env/test/app/core.env`
- `env/test/app/db.env`
- `env/test/db/bootstrap.env`
- `env/test/stack/compose.env`
- `env/example/app/core.env`
- `env/example/app/db.env`
- `env/example/db/bootstrap.env`
- `env/example/stack/compose.env`
- `config/database.yml`
- `env/repo/README.md`
- `env/repo/create.env`
- `env/repo/create.local.env`
- `env/qa/README.md`
- `env/qa/app/core.env`
- `env/qa/stack/compose.env`
- `env/staging/README.md`
- `env/staging/app/core.env`
- `env/staging/stack/compose.env`
- `env/prod/README.md`
- `env/prod/app/core.env`
- `env/prod/stack/compose.env`

## Checklist

- [x] Create or confirm the Rails app baseline.
- [x] Configure Ruby dependencies.
- [->] Add jQuery support. Backlink: [Frontend Toolchain](./003-frontend-toolchain.md)
- [->] Add Bootstrap support. Backlink: [Frontend Toolchain](./003-frontend-toolchain.md)
- [x] Add a Dockerfile for the app.
- [x] Add `compose.yml` for the app and MySQL under `ops/compose/`.
- [x] Use a minimal MySQL image suitable for local development.
- [x] Add database initialization scripts under `ops/containers/db/entrypoint/initdb.d/`.
- [x] Initialize the database and application users through the init scripts.
- [x] Grant the required MySQL privileges for local development.
- [x] Keep environment templates under `env/<env>/{app,db,stack}/`.
- [x] Add command automation for stack and repo workflows via `Makefile` and shell scripts.
- [x] Configure Rails to use `schema.rb`.
- [x] Inject `RUBY_VERSION` from environment variables instead of hardcoding it in the Dockerfile.

## Validation

- [ ] `docker compose --env-file env/dev/stack/compose.env -f ops/compose/compose.yml up --build` starts the database and app services.
- [ ] `make stack/up` starts the database and app services.
- [ ] `make stack/config` renders the compose configuration.
- [ ] `make stack/doctor` validates the stack configuration.
- [ ] `make repo/create` can provision or reconfigure the repository from `env/repo/create.env`.
- [ ] MySQL starts via Compose.
- [ ] The Rails app can connect to the database.
- [ ] Schema dumps are generated as `schema.rb`.

## Notes

- Keep the setup minimal so later work items can build on it without rework.
- If MySQL-specific SQL features are not required, prefer `schema.rb` over `structure.sql`.
- The current bootstrap scope only covers the database and app boundary needed for the Rails baseline.
- `RUBY_VERSION` should come from the environment and be shared across `.tool-versions`, compose, and Docker build args.
- Use `env/<env>/app/core.env`, `env/<env>/app/db.env`, `env/<env>/db/bootstrap.env`, and `env/<env>/stack/compose.env` to avoid cross-consumer leakage.
- `stack/secrets/sync/gh`, `stack/secrets/sync/ci`, and `stack/secrets/sync/vercel` are the standardized secret-sync entry points.
- `prod/`, `qa/`, and `staging/` keep non-secret stack/core env files versioned while local DB credential files remain ignored.
- `env/repo/create.env` is the versioned default for repository provisioning, with `create.local.env` reserved for local overrides.
- `ssl_mode: disabled` is set in `config/database.yml` for local development and test to avoid MySQL 8.4 self-signed TLS issues.

## Related Docs

- `docs/overview.md`
- `docs/sprints/00-foundation/03-data-model.md`
- `docs/sprints/00-foundation/06-quality-and-performance.md`
- `docs/decisions/02-rails-schema-format.md`

## Related Sections

- `docs/sprints/00-foundation/03-data-model.md` -> `## Requirements`
- `docs/sprints/00-foundation/06-quality-and-performance.md` -> `## Stack and UI`
- `docs/sprints/00-foundation/06-quality-and-performance.md` -> `## Performance`
