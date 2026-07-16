---
id: mail-delivery-environment-setup
aliases: []
tags:
  - work-items
  - mail
  - actionmailer
  - environment
  - infrastructure
depends_on:
  - notification-delivery-channels
order: 18
phase: work-items
status: pending
title: Mail Delivery Environment Setup
---

# Mail Delivery Environment Setup

## Goal

- [ ] Configure mail delivery per environment so the PM notification mailer can be previewed locally and delivered in QA/production.

## Scope

- Use a local mail preview tool in development.
- Keep test delivery isolated with the `:test` mailer adapter.
- Configure QA with a real or sandbox mail provider.
- Configure production with real SMTP or transactional mail credentials.
- Keep provider secrets outside the repository.

## Operational Note

- This item is infrastructure and environment wiring, not mail content.
- The PM notification mailer itself is already covered by the notification delivery work item.

## Implementation Plan

- [ ] `config/environments/development.rb` - enable local mail preview for development.
- [ ] `config/environments/test.rb` - keep the `:test` delivery method intact.
- [ ] `config/environments/qa.rb` - configure QA mail delivery for a real or sandbox provider.
- [ ] `config/environments/production.rb` - configure production mail delivery for the chosen provider.
- [ ] `config/credentials` or env vars - store provider secrets outside the repo.
- [ ] `Gemfile` - add the preview tool gem if needed.

## Affected Docs

- `docs/work-items/013-notification-delivery-channels.md`
- `docs/work-items/014-in-app-pm-notifications.md`

## Affected Ops

- `config/environments/development.rb`
- `config/environments/test.rb`
- `config/environments/qa.rb`
- `config/environments/production.rb`
- `config/credentials.yml.enc` or environment variable wiring
- `Gemfile` if a preview tool is added

## Checklist

- [ ] Development can preview PM notification emails locally.
- [ ] Test mail delivery remains isolated and non-networked.
- [ ] QA can send or capture mail through the configured provider.
- [ ] Production uses the intended transactional mail settings.

## Validation

- [ ] A PM notification email can be previewed or inspected in development.
- [ ] Test specs remain deterministic.
- [ ] QA/production mail settings do not leak secrets into source control.

## Notes

- `letter_opener` is the likely development choice unless a better local preview tool already exists in the stack.
- Keep this work item separate from the mailer content so provider setup stays isolated.
