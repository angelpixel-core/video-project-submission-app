---
id: notification-delivery-channels
aliases: []
tags:
  - work-items
  - notifications
  - jobs
  - mail
  - logging
depends_on:
  - sprint-0-background-jobs
order: 13
phase: work-items
status: pending
title: Notification Delivery Channels
---

# Notification Delivery Channels

## Goal

- [ ] Refactor the PM notification flow into explicit delivery channels.

## Scope

- Keep the current log output as one delivery channel.
- Introduce an internal adapter or channel object around the log implementation.
- Add a mail delivery channel for PM notification email.
- Keep the implementation small and composable so more channels can be added later.

## Operational Note

- This item is about delivery plumbing, not UI presentation.
- The logger remains the first working channel and should not be removed.

## Implementation Plan

- [ ] Extract the current log call into a dedicated notification delivery object.
- [ ] Add the mail channel behind the same service boundary.
- [ ] Keep the channel interface small and testable.
- [ ] Add or update specs for each delivery path.

## Affected Docs

- `docs/sprints/00-foundation/05-background-jobs.md`
- `docs/changes/002-notification-job-and-queue-runtime.md`

## Affected Ops

- `app/services/notification_service.rb`
- `app/jobs/notification_job.rb`
- `app/mailers/` if mail delivery is implemented through Action Mailer
- `spec/`

## Checklist

- [ ] The log delivery path still works.
- [ ] The mail delivery path is available behind the same notification flow.
- [ ] Delivery channels are isolated from the job boundary.

## Validation

- [ ] Notification-related specs pass.
- [ ] The PM notification still enqueues asynchronously.

## Notes

- Favor the smallest adapter that cleanly separates channels.
- Keep the log output as a safe fallback and debugging aid.
