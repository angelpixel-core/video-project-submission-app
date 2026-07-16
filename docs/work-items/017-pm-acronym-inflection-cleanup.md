---
id: pm-acronym-inflection-cleanup
aliases: []
tags:
  - work-items
  - rails
  - naming
  - inflections
depends_on:
  - sprint-0-data-model
order: 17
phase: work-items
status: pending
title: PM Acronym Inflection Cleanup
---

# PM Acronym Inflection Cleanup

## Goal

- [ ] Teach Rails to treat `PM` as an acronym and align the naming across the app.

## Scope

- Register `PM` as an acronym in Rails inflections.
- Keep model and constant naming consistent with the acronym.
- Avoid unnecessary renames outside the affected naming boundary.

## Operational Note

- This is a naming cleanup, not a behavior change.
- The change should stay narrow so it does not cascade into unrelated refactors.

## Implementation Plan

- [ ] Add the acronym inflection.
- [ ] Verify autoloading and constant resolution still work.
- [ ] Update any affected references that should use the acronym form.

## Affected Docs

- `docs/sprints/00-foundation/02-domain.md`
- `docs/sprints/00-foundation/03-data-model.md`

## Affected Ops

- `config/initializers/inflections.rb`
- `app/models/`
- `spec/`

## Checklist

- [ ] Rails recognizes `PM` as an acronym.
- [ ] Naming remains consistent in the codebase.

## Validation

- [ ] The app boots cleanly after the inflection change.
- [ ] Specs referencing `PM` continue to pass.

## Notes

- Avoid broad renames unless the acronym cleanup actually requires them.
