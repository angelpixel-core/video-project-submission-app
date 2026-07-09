---
id: testing-foundation
aliases: []
tags:
  - work-items
  - testing
  - rspec
  - capybara
  - webmock
  - vcr
  - cucumber
  - mutant
depends_on:
  - bootstrap-and-environment
order: 2
phase: work-items
status: draft
title: Testing Foundation
---

# Testing Foundation

## Goal

Establish the shared testing stack for Rails, browser-driven system specs, external HTTP recording, and contract validation.

## Scope

- RSpec for unit, request, and integration specs.
- Capybara for browser-driven system specs.
- WebMock for blocking unexpected external HTTP calls.
- VCR for recording and replaying real external HTTP interactions.
- Cucumber for contract-style executable scenarios.
- Mutant for manual contract-level mutation testing.
- Automated test bootstrap for frontend assets so test runs do not require manual asset server steps.

## Directory Layout

```text
spec/
  spec_helper.rb
  rails_helper.rb

  support/
    capybara.rb
    database_cleaner.rb
    factory_bot.rb
    webmock.rb
    vcr.rb
    vcr_cassettes/
    shared_examples/
      api_error_responses.rb
      authentication.rb
    shared_contexts/
      authenticated_user.rb

  unit/
    models/
      project_spec.rb
      submission_spec.rb
    services/
      submission_policy_spec.rb
      notification_dispatcher_spec.rb
    value_objects/
      email_address_spec.rb

  requests/
    health_check_spec.rb
    projects_spec.rb
    submissions_spec.rb
    api/
      v1/
        submissions_spec.rb

  integration/
    repositories/
      project_repository_spec.rb
    workflows/
      create_submission_spec.rb
      publish_project_spec.rb

  smoke/
    auth_smoke_spec.rb
    submission_smoke_spec.rb
    search_smoke_spec.rb

  acceptance/
    features/
      auth/
        sign_in.feature
      submissions/
        create_submission.feature
      projects/
        publish_project.feature
    step_definitions/
      auth_steps.rb
      submission_steps.rb
      project_steps.rb
    support/
      env.rb
      hooks.rb
      capybara.rb
    reports/
      .gitkeep

  contracts/
    api/
      v1/
        submissions_contract_spec.rb
        projects_contract_spec.rb
      openapi/
        submissions_openapi_spec.rb
    manual/
      mutant/
        acceptance_contracts.md

  performance/
    load/
      submissions_load_spec.rb
    benchmarks/
      project_index_benchmark_spec.rb
```

## Layer Philosophy

- `unit`: isolated logic, validations, and error cases.
- `requests`: HTTP status, payload shape, and boundary behavior.
- `integration`: multiple Rails pieces working together.
- `smoke`: minimal critical-path checks.
- `acceptance`: Gherkin business scenarios, executed through Cucumber.
- `contracts`: future OpenAPI/Swagger and manual contract evidence.
- `performance`: load and benchmark coverage.
- `support`: shared configuration for all layers.

## Implementation Tasks

### Core Setup

- Create `spec/spec_helper.rb` and `spec/rails_helper.rb` as the shared RSpec bootstrap.
- Add `spec/support/` for shared test configuration and load it from RSpec.
- Configure `spec/support/factory_bot.rb`, `spec/support/database_cleaner.rb`, `spec/support/webmock.rb`, and `spec/support/vcr.rb`.

### Unit Layer

- Create `spec/unit/models/project_spec.rb` and `spec/unit/models/submission_spec.rb`.
- Create `spec/unit/services/submission_policy_spec.rb` and `spec/unit/services/notification_dispatcher_spec.rb`.
- Create `spec/unit/value_objects/email_address_spec.rb`.

### Request Layer

- Create `spec/requests/health_check_spec.rb`, `spec/requests/projects_spec.rb`, and `spec/requests/submissions_spec.rb`.
- Create `spec/requests/api/v1/submissions_spec.rb` for future API boundary coverage.

### Integration Layer

- Create `spec/integration/repositories/project_repository_spec.rb`.
- Create `spec/integration/workflows/create_submission_spec.rb` and `spec/integration/workflows/publish_project_spec.rb`.

### Smoke Layer

- Create `spec/smoke/auth_smoke_spec.rb`, `spec/smoke/submission_smoke_spec.rb`, and `spec/smoke/search_smoke_spec.rb`.
- Keep smoke coverage narrow and focused on critical paths only.

### Acceptance Layer

- Create `spec/acceptance/features/auth/sign_in.feature`.
- Create `spec/acceptance/features/submissions/create_submission.feature`.
- Create `spec/acceptance/features/projects/publish_project.feature`.
- Create `spec/acceptance/step_definitions/auth_steps.rb`, `spec/acceptance/step_definitions/submission_steps.rb`, and `spec/acceptance/step_definitions/project_steps.rb`.
- Create `spec/acceptance/support/env.rb`, `spec/acceptance/support/hooks.rb`, and `spec/acceptance/support/capybara.rb`.
- Create `spec/acceptance/reports/.gitkeep` so manual acceptance output has a stable home.

### Contract Layer

- Create `spec/contracts/api/v1/submissions_contract_spec.rb` and `spec/contracts/api/v1/projects_contract_spec.rb`.
- Reserve `spec/contracts/api/openapi/submissions_openapi_spec.rb` for future `rswag` / OpenAPI expansion.
- Create `spec/contracts/manual/mutant/acceptance_contracts.md` for manual mutation-testing notes and evidence.

### Performance Layer

- Create `spec/performance/load/submissions_load_spec.rb`.
- Create `spec/performance/benchmarks/project_index_benchmark_spec.rb`.

### Command and Runtime Integration

- Add or update `bin/rspec` and `bin/cucumber` so the suite runs from the repo root without manual path juggling.
- Wire test asset bootstrapping into the app/test entrypoint so frontend assets are available automatically.
- Ensure all test-layer directories are loaded from `spec/` and that Cucumber reads from `spec/acceptance/features`.

## Out of Scope

- The frontend implementation details for Bootstrap and jQuery.
- API documentation generation beyond the initial contract shape.
- Non-Rails test frameworks unless explicitly introduced later.

## Affected Docs

- `docs/work-items/001-bootstrap-and-environment.md`
- `docs/sprints/00-foundation/06-quality-and-performance.md`
- `docs/sprints/00-foundation/07-acceptance-criteria.md`

## Affected Ops

- `Gemfile`
- `bin/rspec`
- `bin/cucumber`
- `spec/`
- `ops/containers/app/entrypoint.sh`
- `ops/containers/app/Dockerfile`

## Checklist

- [x] Core RSpec bootstrap and shared support files exist.
- [x] Unit, request, integration, smoke, acceptance, contract, and performance directories exist under `spec/`.
- [x] Cucumber acceptance features live under `spec/acceptance/features`.
- [x] Manual acceptance reports have a stable output directory.
- [x] Contract specs reserve a future OpenAPI / Swagger path.
- [ ] Frontend assets are available automatically during test runs.
- [x] The testing hierarchy remains entirely under `spec/`.

## Validation

- [x] `bin/rspec` runs unit and request specs without manual asset steps.
- [x] `ops/scripts/test.sh verify` builds the `test` image stage, starts the isolated test DB, and loads Rails successfully.
- [ ] External HTTP calls are blocked unless explicitly recorded.
- [ ] `VCR` artifacts can be reviewed and shared.
- [x] `bin/cucumber` runs manually and emits persistent reports.
- [ ] Mutant is not invoked automatically by the agent flow.
- [x] Example directories exist for each testing layer under `spec/`.

## Notes

- Prefer a hybrid contract model: a central testing foundation plus per-work-item contract references.
- Keep Cucumber manual-only so the mutation-heavy contract layer stays under explicit human control.
- Treat request specs as the base for any future OpenAPI/Swagger layer.
- Keep all test architecture under `spec/` so tooling follows the repo's structure, not the other way around.
- Test asset bootstrapping should be transparent to day-to-day commands.
- Implemented so far: core setup, unit, request, integration, smoke, acceptance, contracts, and performance layers.

## Related Docs

- `docs/work-items/004-frontend-toolchain.md`
- `docs/overview.md`
- `docs/sprints/00-foundation/06-quality-and-performance.md`
- `docs/sprints/00-foundation/07-acceptance-criteria.md`

## Related Sections

- `docs/sprints/00-foundation/06-quality-and-performance.md` -> `## Stack and UI`
- `docs/sprints/00-foundation/06-quality-and-performance.md` -> `## Code Quality`
- `docs/sprints/00-foundation/07-acceptance-criteria.md` -> `## Evaluation Focus`
