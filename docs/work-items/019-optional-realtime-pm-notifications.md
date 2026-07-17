---
id: optional-realtime-pm-notifications
aliases: []
tags:
  - work-items
  - notifications
  - realtime
  - pm
  - optional
depends_on:
  - in-app-pm-notifications
order: 19
phase: work-items
status: pending
title: Optional Realtime PM Notifications
---

# Optional Realtime PM Notifications

## Goal

- [ ] Stream PM notifications in real time when the PM has the view open, but keep the feature optional and non-blocking.

## Scope

- Add realtime delivery only if it remains simple in the current stack.
- Keep the server-rendered PM inbox and acknowledgment flow as the baseline.
- Do not block completion of the in-app notification work on this slice.

## Operational Note

- This item exists only to defer the realtime stretch goal from work item 14.
- The PM notifications feature is already usable without realtime.

## Implementation Plan

- [ ] `app/channels/` - add the realtime channel if the stack supports it cleanly.
- [ ] `app/javascript/` - subscribe to the realtime stream if needed by the chosen transport.
- [ ] `app/controllers/` or `app/models/` - broadcast unread notifications on create or acknowledgment changes.
- [ ] `spec/system/` or `spec/integration/` - verify the PM sees updates without refreshing when realtime is enabled.

## Affected Docs

- `docs/work-items/014-in-app-pm-notifications.md`

## Affected Ops

- `app/channels/`
- `app/javascript/`
- `app/controllers/`
- `app/models/`
- `spec/system/`
- `spec/integration/`

## Checklist

- [ ] PM notifications can appear without a page refresh when realtime is enabled.
- [ ] The baseline in-app notification flow still works without realtime.

## Validation

- [ ] Realtime specs pass only if the implementation is kept simple enough to support them.

## Notes

- Keep this item optional and smaller than the core notification work.
- If realtime gets too complex, keep the baseline flow and stop here.
