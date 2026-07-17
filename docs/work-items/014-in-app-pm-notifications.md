---
id: in-app-pm-notifications
aliases: []
tags:
  - work-items
  - notifications
  - ui
  - realtime
  - pm
depends_on:
  - notification-delivery-channels
  - sprint-0-client-views
  - sprint-0-data-model
order: 14
phase: work-items
status: pending
title: In-App PM Notifications
---

# In-App PM Notifications

## Goal

- [ ] Show PM notifications inside the app as toasts/snackbars and persist their read state.

## Scope

- Persist notifications in the database as the source of truth.
- Add a `read_at` or `seen_at` field to track acknowledgment.
- Render pending notifications when the PM enters the PM view.
- Optionally stream new notifications in real time when the PM has the view open, but do not block the work item on it.
- Mark notifications as seen/read when the PM acknowledges them.
- Keep the acknowledgment UI and its minimal non-Bootstrap styling as a contiguous subslice of this work item.

## Discovery

- `read_at` already exists in the notifications table and schema, so the first slice only needs model behavior and specs.
- The PM inbox is rendered server-side on `projects#index` for now; the acknowledgment UI remains a contiguous follow-up slice.

## Operational Note

- This item is about in-app presentation, not browser push notifications.
- A toast acknowledgment should mean the PM actually saw the notification, not just closed it.

## Implementation Plan

- [x] `db/schema.rb` - confirm the read-state column already exists for `notifications`.
- [x] `app/models/notification.rb` - add the read-state validation or helper methods needed for unread queries.
- [x] `app/controllers/projects_controller.rb` - load unread notifications when the PM view opens.
- [x] `app/views/projects/index.html.erb` - render a compact PM inbox for each pending notification.
- [x] `app/views/projects/_notification.html.erb` - render the compact notification card/preview.
- [ ] `app/javascript/` or `app/assets/` - add the minimal client behavior for closing/acknowledging the toast.
- [ ] `app/assets/stylesheets/` or the current frontend style layer - add the small custom CSS needed for the toast/ack component.
- [x] `spec/requests/projects_spec.rb` - verify the PM inbox renders unread notifications and excludes read ones.
- [ ] `spec/system/` - verify the toast appears and can be acknowledged.
- [x] `spec/models/` or `spec/unit/models/` - verify the unread/read state behavior.
- [ ] Realtime delivery only if it stays simple enough for the current stack.

## Affected Docs

- `docs/sprints/00-foundation/04-client-views.md`
- `docs/sprints/00-foundation/05-background-jobs.md`
- `docs/sprints/00-foundation/02-domain.md`

## Affected Ops

- `app/models/notification.rb`
- `app/views/`
- `app/controllers/`
- `app/javascript/` or `app/assets/` depending on the UI approach
- `spec/system/`
- `spec/models/` or `spec/unit/models/`

## Checklist

- [ ] PM notifications are visible in the app.
- [ ] Pending notifications appear when the PM enters the view.
- [ ] Acknowledged notifications are marked as read.

## Validation

- [ ] UI specs verify the toast and acknowledgment flow.
- [ ] Unread notifications are loaded from persistence.
- [ ] The acknowledgment updates the stored read state.

## Notes

- Prefer a notification list plus a minimal toast over a detail screen.
- Keep the payload compact: project name, client name, and a short message are enough.
