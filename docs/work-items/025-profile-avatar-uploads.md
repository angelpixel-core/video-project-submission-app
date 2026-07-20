---
id: profile-avatar-uploads
aliases: []
tags:
  - work-items
  - profile
  - avatar
  - activestorage
  - auth
  - user
depends_on:
  - avatar-navbar-account-menu
  - role-switcher-prototype
order: 25
phase: work-items
status: pending
title: Profile and Avatar Uploads
---

# Profile and Avatar Uploads

## Goal

- [ ] Add a profile page with user details, avatar support, and demo credential visibility.

## Scope

- Add a `/profile` page.
- Show the user's name, email, and current role.
- Show a demo token/credential with copy and reveal controls.
- Use a CSS/SVG placeholder avatar when no image is present.
- Support an optional avatar image via `ActiveStorage`.
- Allow either file upload or a safe `https://` avatar URL where appropriate.
- Keep the placeholder avatar available even when no image or URL exists.
- Seed/populate the demo user through a data migration or equivalent bootstrapping step.

## Operational Note

- This is a profile and asset-management change, not a full auth refactor.
- The app session remains the primary login mechanism for now.
- `ActiveStorage` should be local in development and configurable for other environments.
- The token shown on the profile page is a demo credential, not the browser session itself.

## Implementation Plan

- [ ] `app/views/profile/show.html.erb` or equivalent - render the profile details and avatar area.
- [ ] `app/controllers/profile_controller.rb` or equivalent - load the current user profile.
- [ ] `app/models/` - add or extend the user/profile model as needed for avatar support.
- [ ] `ActiveStorage` - attach and serve the avatar image optionally.
- [ ] `db/migrate/` or `lib/tasks` / data migration - seed the demo user/profile data.
- [ ] `app/frontend/entrypoints/application.css` - style the avatar, token reveal, and copy actions.
- [ ] `spec/system/` - verify profile rendering, avatar fallback, and token controls.

## Affected Docs

- `docs/work-items/index.md`
- `docs/work-items/024-avatar-navbar-account-menu.md`

## Affected Ops

- `app/views/profile/`
- `app/controllers/profile_controller.rb`
- `app/models/`
- `db/migrate/`
- `app/frontend/entrypoints/application.css`
- `spec/system/`

## Checklist

- [ ] `/profile` shows name, email, and role.
- [ ] The avatar placeholder renders when no image is present.
- [ ] An uploaded avatar can be attached via `ActiveStorage`.
- [ ] A demo token can be revealed and copied.
- [ ] The profile page matches the existing visual system.

## Validation

- [ ] System spec verifies profile details render.
- [ ] System spec verifies avatar fallback and attachment behavior.
- [ ] System spec verifies token reveal/copy controls.

## Notes

- Favor a deterministic placeholder avatar so the UI always works without uploads.
- Keep the profile controls simple; avoid mixing auth migration work into the UI task.
