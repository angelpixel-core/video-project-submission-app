---
id: localization-routing-and-internationalization-plan
aliases: []
tags:
  - work-items
  - i18n
  - localization
  - routing
  - middleware
  - translations
depends_on:
  - application-boundaries-and-repositories
  - avatar-navbar-account-menu
order: 51
phase: work-items
status: planned
title: Localization Routing and Internationalization Plan
---

# Localization Routing and Internationalization Plan

## Goal

- [ ] Add locale-aware routing, request resolution, and translation support with `es` as the only non-English locale for now.

## Scope

- Add a locale prefix to public application routes, such as `/es/orders`.
- Resolve locale early in the request lifecycle with a Rack middleware.
- Keep `en` as the fallback locale.
- Persist the user's preferred locale from the profile screen.
- Preserve the active locale in generated links and navigation.
- Extract hardcoded UI copy into translation files.

## Current Codebase

- `config/routes.rb` currently exposes all app routes without a locale scope.
- `app/controllers/application_controller.rb` already centralizes shared request context.
- `app/views/layouts/application.html.erb` contains the main navigation and is the natural place for a language switcher.
- `app/views/profile/show.html.erb` is the existing account settings surface.
- `app/frontend/controllers/workspace_switch_controller.js` already demonstrates a client-side persistence pattern.
- `config/locales/en.yml` exists, but `config/locales/es.yml` does not yet.
- `users.preferred_locale` already exists in the data model.

## Design Notes

- Use `es` only for the first rollout; do not introduce `es-AR` as a separate locale unless the product later needs regional variants.
- Treat the URL locale as the strongest navigation signal for a request.
- Treat the user's saved `preferred_locale` as the persistent account-level default.
- Keep middleware responsible for request context, not for business rules.
- Use short translation keys in views where Rails supports it, and explicit keys in controllers/services/mailers.

## Implementation Plan

### Phase 1: Locale foundation

- [ ] Define `I18n.available_locales`, `I18n.default_locale`, and fallbacks in app configuration.
- [ ] Add a Rack middleware that resolves locale from the URL prefix and applies `I18n.with_locale`.
- [ ] Wrap app routes in a locale scope so locale-prefixed URLs work everywhere they should.
- [ ] Add `default_url_options` so generated links preserve the active locale.

### Phase 2: User preference persistence

- [ ] Add profile-level persistence for `preferred_locale`.
- [ ] Update the profile update flow so a locale change stores the user's preference.
- [ ] Make the language switcher respect the active locale when navigating between pages.

### Phase 3: UI and translations

- [ ] Add a language switch button in the main layout.
- [ ] Extract shared copy from the navbar, profile page, and orders index into translation files.
- [ ] Create `config/locales/es.yml` and split shared copy into focused locale files as needed.
- [ ] Use short translation keys in views where it improves readability.

### Phase 4: Verification and cleanup

- [ ] Add request specs for locale-prefixed and non-prefixed routes.
- [ ] Add controller or system coverage for changing language from the UI.
- [ ] Verify the locale persists in generated links after navigation.
- [ ] Confirm English fallback still works when no locale is provided.

## Expected Result

- `/es/...` renders the application in Spanish.
- Plain URLs continue to render in English unless the user's saved preference says otherwise.
- The active locale persists through navigation.
- Translation files replace hardcoded UI copy incrementally, without forcing a full rewrite in one pass.

## Affected Docs

- `docs/work-items/index.md`

## Affected Ops

- `config/application.rb`
- `config/routes.rb`
- `lib/middleware/locale_middleware.rb`
- `app/controllers/application_controller.rb`
- `app/controllers/profile_controller.rb`
- `app/views/layouts/application.html.erb`
- `app/views/profile/show.html.erb`
- `app/views/orders/index.html.erb`
- `config/locales/en.yml`
- `config/locales/es.yml`
- `config/locales/*.yml`

## Checklist

- [ ] Locale-prefixed routes resolve correctly.
- [ ] The active locale is applied before controllers run.
- [ ] The profile page can persist `preferred_locale`.
- [ ] Links keep the current locale when navigating.
- [ ] English remains the default fallback.
- [ ] Spanish copy exists for the main navigation and primary account screens.

## Validation

- [ ] Request spec for `/orders` and `/es/orders`.
- [ ] Request or controller spec for locale resolution priority.
- [ ] UI spec for the language switcher preserving locale in links.
- [ ] Translation lookup smoke check for the main layout and profile page.

## Notes

- This work item is intentionally phased so routing, persistence, and content extraction can land separately.
- The first release only needs one extra locale: Spanish.
