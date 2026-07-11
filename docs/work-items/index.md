---
id: work-items-index
title: Work Items Index
phase: work-items
order: 0
aliases: []
tags:
  - work-items
  - tickets
  - implementation
---

# Work Items Index

Work items are implementation documents. Each one should map back to the docs it resolves and the checklist items it affects.

## Standard Frontmatter

- `id`
- `title`
- `phase: work-items`
- `order`
- `status`
- `depends_on`
- `tags`

## Standard Content

- `## Goal`
- `## Scope`
- `## Affected Docs`
- `## Affected Ops`
- `## Checklist`
- `## Validation`
- `## Notes`
- `## Related Docs`
- `## Related Sections`

## Naming

- Use numeric prefixes for ordering.
- Keep the title focused on the implementation outcome.
- Add one work item per coherent unit of development.

## First Item

- [x] [Bootstrap and Environment](./001-bootstrap-and-environment.md)

## Second Item

- [x] [Testing Foundation](./002-testing-foundation.md)

## Third Item

- [x] [CI/CD and Environments](./003-ci-cd-and-environments.md)

## Fourth Item

- [x] [Frontend Toolchain](./004-frontend-toolchain.md)

## Fifth Item

- [ ] [SSH Authentication and Commit Signing](./005-ssh-authentication-and-commit-signing.md)

## Sixth Item

- [ ] [Render Infrastructure Requirements](./006-render-infrastructure-requirements.md)

## Seventh Item

- [ ] [Database Engine and IaC Strategy](./007-database-engine-and-iac-strategy.md)
