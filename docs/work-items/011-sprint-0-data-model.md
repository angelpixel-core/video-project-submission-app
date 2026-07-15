---
id: sprint-0-data-model
aliases: []
tags:
  - work-items
  - sprint-0
  - database
  - models
  - migrations
  - seeds
depends_on:
  - bootstrap-and-environment
  - testing-foundation
order: 11
phase: work-items
status: draft
title: Sprint 0 Data Model
---

# Sprint 0 Data Model

## Goal

- [ ] Implement the Sprint 0 domain model with migrations, seeds/fixtures, and basic validations.

## Scope

- Client, Project, PM, VideoType, VideoTypeSelection, Notification models.
- MySQL-backed migrations for the Sprint 0 relationships.
- Seed data or fixtures for default PMs and available video types.
- Basic model validations for required attributes and associations.
- Keep the data model aligned with the `VideoType` decision already recorded in Sprint 0.

## Operational Note

- This work item is the persistence layer for Sprint 0.
- The `VideoType` naming decision is already fixed; this item should implement it, not revisit it.

## Implementation Plan

- [ ] Add/adjust Active Record models for the Sprint 0 entities.
- [ ] Create the migrations needed for the relationships and constraints.
- [ ] Seed the default PM and the initial catalog of video types.
- [ ] Add basic validations on model attributes and associations.
- [ ] Add or update the minimal model specs needed to verify the relationships and validations.
- [ ] Confirm MySQL compatibility with the existing environment setup.

## Affected Docs

- `docs/sprints/00-foundation/02-domain.md`
- `docs/sprints/00-foundation/03-data-model.md`
- `docs/sprints/00-foundation/99-open-questions.md`

## Affected Ops

- `app/models/`
- `db/migrate/`
- `db/seeds.rb`
- `db/fixtures/` or equivalent seed/fixture files if needed
- `spec/models/`
- `test/models/` if the project uses Minitest for model coverage

## Checklist

- [ ] The Sprint 0 models and relationships exist in Rails.
- [ ] The database migrations support the modeled relationships.
- [ ] The seeded PM and video types are available for development and validation.
- [ ] Basic validations prevent invalid records.

## Validation

- [ ] The model tests/specs pass.
- [ ] The seeded data loads successfully.
- [ ] The relationships match the Sprint 0 domain docs.

## Notes

- Favor the simplest implementation that satisfies the Sprint 0 docs.
- Keep the seed data small and deterministic.
