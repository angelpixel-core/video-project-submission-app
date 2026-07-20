---
id: profile-avatar-storage
aliases: []
tags:
  - work-items
  - profile
  - avatar
  - activestorage
  - upload
  - storage
depends_on:
  - profile-read-only-view
order: 27
phase: work-items
status: pending
title: Profile Avatar Storage
---

# Profile Avatar Storage

## Goal

- [ ] Add optional avatar persistence to the `/profile` page using `ActiveStorage`.

## Scope

- Allow the user to attach an avatar image.
- Keep the CSS/SVG placeholder when no avatar exists.
- Support removing or replacing the current avatar.
- Keep the profile page otherwise read-only for identity fields.
- Keep local development working with local disk storage.
- Do not introduce the full auth refactor yet.

## Operational Note

- This is the storage/upload step after the read-only profile has been validated.
- The browser session remains the source of login state.
- The avatar is optional; the placeholder must always render.

## Implementation Plan

- [ ] `ActiveStorage` setup for local development.
- [ ] `app/models/` - attach avatar to the profile/user model.
- [ ] `app/views/profile/show.html.erb` or equivalent - show current avatar and upload control.
- [ ] `app/frontend/entrypoints/application.css` - style upload state and preview.
- [ ] `spec/system/` - verify upload, replace, and fallback behavior.

## Affected Docs

- `docs/work-items/index.md`
- `docs/work-items/026-profile-read-only-view.md`

## Affected Ops

- `app/models/`
- `app/views/profile/`
- `app/frontend/entrypoints/application.css`
- `spec/system/`
- `db/migrate/` or `storage/` setup if needed

## Checklist

- [ ] Avatar can be uploaded.
- [ ] Avatar preview renders when present.
- [ ] Placeholder renders when missing.
- [ ] Profile page still matches the app shell.

## Validation

- [ ] System spec verifies upload and preview.
- [ ] System spec verifies fallback placeholder.
- [ ] System spec verifies replace/remove behavior.

## Notes

- If you want avatar URLs too, that can be a later extension.
- This should stay separate from the auth/session refactor.
