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

- [ ] [Bootstrap and Environment](./001-bootstrap-and-environment.md)
