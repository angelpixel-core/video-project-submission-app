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
- Render pending notifications when the PM enters the PM view.
- Optionally stream new notifications in real time when the PM has the view open.
- Mark notifications as seen/read when the PM acknowledges them.

## Operational Note

- This item is about in-app presentation, not browser push notifications.
- A toast acknowledgment should mean the PM actually saw the notification, not just closed it.

## Implementation Plan

- [ ] Decide the read-state attribute name and persistence pattern.
- [ ] Load unread notifications when the PM view opens.
- [ ] Render a compact toast/snackbar for each pending notification.
- [ ] Add an acknowledgment action that marks the notification as read.
- [ ] Add realtime delivery only if it stays simple enough for the current stack.

## Affected Docs

- `docs/sprints/00-foundation/04-client-views.md`
- `docs/sprints/00-foundation/05-background-jobs.md`
- `docs/sprints/00-foundation/02-domain.md`

## Affected Ops

- `app/models/notification.rb`
- `app/views/`
- `app/controllers/`
- `app/javascript/` or `app/assets/` depending on the UI approach
- `spec/system/` or `spec/requests/`

## Checklist

- [ ] PM notifications are visible in the app.
- [ ] Pending notifications appear when the PM enters the view.
- [ ] Acknowledged notifications are marked as read.

## Validation

- [ ] UI specs verify the toast and acknowledgment flow.
- [ ] Unread notifications are loaded from persistence.

## Notes

- Prefer a notification list plus a minimal toast over a detail screen.
- Keep the payload compact: project name, client name, and a short message are enough.
