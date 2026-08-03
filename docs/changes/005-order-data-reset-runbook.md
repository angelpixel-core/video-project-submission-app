---
id: order-data-reset-runbook
title: Order Data Reset Runbook
phase: changes
order: 5
aliases: []
tags:
  - changes
  - runbook
  - cleanup
  - orders
  - data-reset
---

# Order Data Reset Runbook

## Goal

- [x] Reset all order-owned data while preserving clients, PMs, and video types.

## When To Use

- Rebuild a local demo database from scratch without recreating users.
- Clear stale orders, payments, notifications, comments, and webhook history.
- Prepare a clean environment for validating order setup flows.

## What Gets Removed

- `projects`
- `video_type_selections`
- `payments`
- `payment_attempts`
- `payment_webhook_events`
- `payment_webhook_event_attempts`
- `payment_notification_intents`
- `comments`
- `notifications`

## What Stays

- `clients`
- `pms`
- `video_types`
- attached avatars on clients and PMs

## Command

```bash
make maintenance/reset_order_data DRY_RUN=1
```

```bash
make maintenance/reset_order_data CONFIRM=YES
```

## Expected Result

- The dry run prints row counts for every order-owned table.
- The confirmed run deletes those rows in dependency-safe order.
- Clients, PMs, and video types remain untouched.

## Verify

1. Open a Rails console and confirm `Client.count`, `PM.count`, and `VideoType.count` stay non-zero.
2. Confirm `Order.count`, `Payment.count`, `Comment.count`, and `Notification.count` are `0`.
3. Confirm `PaymentWebhookEvent.count` and `PaymentNotificationIntent.count` are `0`.

## Notes

- Run this only when you really want to wipe all order data.
- `DRY_RUN=1` is safe and prints what will be deleted without changing the database.
- The task intentionally skips clients, PMs, and video types so demo users and catalog data can be reused.
