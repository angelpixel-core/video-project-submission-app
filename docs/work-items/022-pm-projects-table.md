---
id: pm-projects-table
aliases: []
tags:
  - work-items
  - pm
  - projects
  - table
  - realtime
  - ui
depends_on:
  - floating-pm-notifications
order: 22
phase: work-items
status: pending
title: PM Projects Table
---

# PM Projects Table

## Goal

- [ ] Show PM projects as a table with realtime updates, sorted by creation date.

## Scope

- Render the PM project list as a table only in PM mode.
- Keep the client view unchanged.
- Show project ID, project name, created date, total budget, status, and actions.
- Sort PM projects by `created_at DESC`.
- Do not show video type details in the table.
- Reserve video type breakdown for `projects#show`.
- Compute total budget from `video_type.price_cents * quantity` across project selections.
- Append newly created projects into the PM table in realtime when the client submits a project.
- Keep the PM notification flow working alongside the table updates.

## Operational Note

- This is a PM-only presentation change.
- The table is a summary view, not a replacement for `projects#show`.
- Realtime insertion should stay aligned with the existing notification broadcast path.

## Implementation Plan

- [ ] `app/views/projects/index.html.erb` - replace the PM grid with a table view in PM mode.
- [ ] `app/controllers/projects_controller.rb` - ensure PM projects are loaded sorted by `created_at DESC` and expose any data needed for the budget column.
- [ ] `app/models/project.rb` or a presenter/helper - compute total budget from selections.
- [ ] `app/views/projects/_pm_project_table_row.html.erb` or similar - render a single PM table row.
- [ ] `app/frontend/channels/pm_notification_channel.js` - update the PM table in realtime when a new project is submitted.
- [ ] `app/frontend/entrypoints/application.css` - add table styling consistent with the current editorial theme.
- [ ] `spec/requests/projects_spec.rb` - verify PM table copy and ordering.
- [ ] `spec/system/projects_notifications_spec.rb` - verify realtime row insertion and PM-mode-only rendering.

## Affected Docs

- `docs/work-items/index.md`
- `docs/work-items/021-floating-pm-notifications.md`

## Affected Ops

- `app/views/projects/index.html.erb`
- `app/controllers/projects_controller.rb`
- `app/views/projects/_pm_project_table_row.html.erb` or equivalent
- `app/frontend/channels/pm_notification_channel.js`
- `app/frontend/entrypoints/application.css`
- `spec/requests/projects_spec.rb`
- `spec/system/projects_notifications_spec.rb`

## Checklist

- [ ] PM mode shows a table instead of cards.
- [ ] The table includes ID, project name, created date, total budget, status, and actions.
- [ ] The PM table is sorted by newest project first.
- [ ] Video type details are not shown in the table.
- [ ] Total budget matches the sum of selected video types and quantities.
- [ ] New client-created projects appear in the PM table in realtime.
- [ ] Client mode remains unchanged.

## Validation

- [ ] Request spec verifies PM table structure and ordering.
- [ ] System spec verifies PM mode renders the table and client mode does not.
- [ ] System spec verifies a newly created project appears in the PM table without a full refresh.
- [ ] Unit/spec coverage verifies budget calculation from project selections.

## Notes

- Prefer a table partial for each row rather than embedding complex row logic in the main index view.
- Keep the realtime update aligned with the notification broadcast path to avoid duplicate refresh logic.
- If the table grows too wide, keep it horizontally readable rather than collapsing into cards.
