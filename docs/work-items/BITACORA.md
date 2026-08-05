# Bitacora de Work Items

## 001 Bootstrap and Environment

- **What**: Established the Rails baseline, local Docker/MySQL environment, init scripts, `schema.rb`, and stage-separated environment templates.
- **Why**: To provide the minimum runnable foundation for the project before higher-level frontend, infra, and domain work.
- **Where**: `ops/compose/compose.yml`, `ops/containers/app/Dockerfile`, `ops/containers/db/entrypoint/initdb.d/001-bootstrap.sh`, `config/database.yml`, `env/*`
- **Learned**: Keep bootstrap minimal, prefer `schema.rb` over `structure.sql` when possible, and use per-consumer env templates to avoid leakage between app/db/stack/repo provisioning.

## 002 Testing Foundation

- **What**: Defined the shared testing stack and directory structure for RSpec, Capybara, WebMock, VCR, Cucumber, and manual Mutant evidence.
- **Why**: To standardize testing across unit, request, integration, smoke, acceptance, contract, and performance layers.
- **Where**: `spec/`, `bin/rspec`, `bin/cucumber`, `ops/containers/app/entrypoint.sh`, `ops/containers/app/Dockerfile`, `Gemfile`
- **Learned**: Keep test architecture under `spec/`, make Cucumber manual-only, and treat request specs as the base for future API contract generation.

## 003 CI/CD and Environments

- **What**: Defined the end-to-end delivery pipeline across local/dev, CI/test, QA, staging, and production with promotion rules and environment-specific image stages.
- **Why**: To make deployment behavior explicit, deterministic, and gated from local development through production.
- **Where**: `Makefile`, `ops/scripts/stack.sh`, `ops/scripts/repo/create.sh`, `ops/compose/compose.yml`, `ops/containers/app/Dockerfile`, `docs/work-items/001-bootstrap-and-environment.md`
- **Learned**: Keep QA, staging, and prod separate on purpose; run lint early once; and make PR automation use a dedicated token plus manual merge control.
