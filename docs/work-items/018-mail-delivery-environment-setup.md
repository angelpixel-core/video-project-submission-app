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

- Use `letter_opener` for local mail previews in development.
- Keep test delivery isolated with the `:test` mailer adapter.
- Configure QA with SMTP settings provided through environment variables.
- Configure production with SMTP settings provided through environment variables.
- Keep provider secrets outside the repository and in the existing `ENV`/secret vars convention.

## Operational Note

- This item is infrastructure and environment wiring, not mail content.
- The PM notification mailer itself is already covered by the notification delivery work item.

## Implementation Plan

- [x] `Gemfile` - add `letter_opener` for development previews.
- [x] `config/environments/development.rb` - enable `letter_opener` for development.
- [x] `config/environments/test.rb` - keep the `:test` delivery method intact.
- [ ] `config/environments/qa.rb` - configure QA mail delivery from environment variables.
- [ ] `config/environments/production.rb` - configure production mail delivery from environment variables.
- [ ] `env/*/app/*.env` and/or deploy secrets - document the SMTP variables required per environment.

## Affected Docs

- `docs/work-items/013-notification-delivery-channels.md`
- `docs/work-items/014-in-app-pm-notifications.md`

## Affected Ops

- `config/environments/development.rb`
- `config/environments/test.rb`
- `config/environments/qa.rb`
- `config/environments/production.rb`
- `env/*/app/*.env` and deploy secret wiring
- `Gemfile`

## Checklist

- [ ] Development can preview PM notification emails locally.
- [ ] Test mail delivery remains isolated and non-networked.
- [ ] QA can send or capture mail using SMTP settings from environment variables.
- [ ] Production uses the intended transactional mail settings from environment variables.
- [ ] The repo stays on the `ENV`/secret vars convention for mail secrets.

## Validation

- [ ] A PM notification email can be previewed or inspected in development.
- [ ] Test specs remain deterministic.
- [ ] QA/production mail settings do not leak secrets into source control.

## Notes

- `letter_opener` is the chosen development preview tool.
- Keep this work item separate from the mailer content so provider setup stays isolated.
- QA/production should keep using the repo's existing environment-variable secret wiring; do not switch this work item to Rails credentials.
