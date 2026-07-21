---
id: project-status-badge-realtime
aliases: []
tags:
  - work-items
  - project
  - status
  - badge
  - realtime
  - actioncable
depends_on:
  - project-lifecycle-states
  - client-notifications-persistent-toasts
  - in-app-pm-notifications
order: 36
phase: work-items
status: done
title: Project Status Badge Realtime
---

# Project Status Badge Realtime

## Goal

- [x] Keep project status badges in sync in realtime for client and PM views when the project lifecycle changes.

## Scope

- Broadcast project status changes over ActionCable.
- Render the status badge through a shared partial so client and detail views stay consistent.
- Subscribe client project cards and the project show page to live status updates.
- Reuse the new badge helpers in PM project cards and table rows for consistent labels.
- Add a regression system spec that verifies the badge updates without a full reload.

## Operational Note

- This work should stay on the existing ActionCable stack used by notifications and comments.
- Keep the badge payload small and HTML-based to avoid duplicating presentation logic in JS.

## Implementation Plan

- [x] Add a `ProjectStatusChannel` that streams updates per project id.
- [x] Broadcast rendered badge HTML from `Project` after status changes.
- [x] Add a shared `projects/_status_badge` partial.
- [x] Mount the badge in the client project card and project show page.
- [x] Subscribe the frontend entrypoint to project status updates.
- [x] Add a system spec for the live badge update flow.

## Affected Docs

- `docs/work-items/015-project-lifecycle-states.md`
- `docs/work-items/028-client-notifications-persistent-toasts.md`
- `docs/work-items/index.md`

## Affected Ops

- `app/models/project.rb`
- `app/channels/project_status_channel.rb`
- `app/frontend/channels/project_status_channel.js`
- `app/frontend/entrypoints/application.js`
- `app/views/projects/_project.html.erb`
- `app/views/projects/show.html.erb`
- `app/views/projects/_status_badge.html.erb`
- `app/views/projects/_pm_project.html.erb`
- `app/views/projects/_pm_project_table_row.html.erb`
- `spec/system/project_status_badge_realtime_spec.rb`

## Checklist

- [x] Changing a project status broadcasts a live update.
- [x] Client project cards show the new status without reload.
- [x] Project show updates its status badge without reload.
- [x] PM project views reuse the same badge labels.

## Validation

- [x] A system spec covers the realtime badge update path.
- [x] The new spec passes in headless Chrome.

## Notes

- The regression spec sets the workspace env vars locally so it can run in isolation.
