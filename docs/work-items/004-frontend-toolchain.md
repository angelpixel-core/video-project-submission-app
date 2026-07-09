---
id: frontend-toolchain
aliases: []
tags:
  - work-items
  - frontend
  - vite
  - bootstrap
  - jquery
depends_on:
  - testing-foundation
order: 4
phase: work-items
status: draft
title: Frontend Toolchain
---

# Frontend Toolchain

## Goal

Set up Vite as the frontend toolchain and manage Bootstrap/jQuery as frontend dependencies.

## Scope

- Vite-based asset pipeline.
- Bootstrap installed via frontend dependencies.
- jQuery installed via frontend dependencies.
- Hot reload friendly development flow.
- Removal or bypass of importmap-based frontend management.

## Affected Docs

- `docs/work-items/001-bootstrap-and-environment.md`
- `docs/work-items/002-testing-foundation.md`
- `docs/work-items/003-ci-cd-and-environments.md`
- `docs/sprints/00-foundation/06-quality-and-performance.md`

## Affected Ops

- `Gemfile`
- `config/application.rb`
- `app/views/layouts/application.html.erb`
- `package.json`
- `ops/containers/app/Dockerfile`
- `ops/containers/app/entrypoint.sh`

## Checklist

- [ ] Add Vite support to the Rails application.
- [ ] Add a `package.json` for frontend dependencies.
- [ ] Install Bootstrap through the frontend toolchain.
- [ ] Install jQuery through the frontend toolchain.
- [ ] Wire Vite into the application layout.
- [ ] Remove or disable importmap-based frontend management.
- [ ] Ensure hot reload works in development.

## Validation

- [ ] The app boots with Vite enabled.
- [ ] Frontend dependencies are served through Vite.
- [ ] Bootstrap styles load in the app layout.
- [ ] jQuery is available to frontend code.
- [ ] Hot reload reflects frontend changes.

## Notes

- Keep Rails responsible for the backend and Vite responsible for frontend assets.
- Bootstrap and jQuery should be treated as frontend dependencies, not Rails-managed assets.

## Related Docs

- `docs/work-items/001-bootstrap-and-environment.md`
- `docs/work-items/002-testing-foundation.md`
- `docs/work-items/003-ci-cd-and-environments.md`
- `docs/overview.md`

## Related Sections

- `docs/sprints/00-foundation/06-quality-and-performance.md` -> `## Stack and UI`
- `docs/sprints/00-foundation/06-quality-and-performance.md` -> `## Code Quality`
