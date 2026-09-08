# Identity Route Map

Identity es la capa de workspace y access para el shell del marketplace de videos.

Hoy es responsable de:

- user identity y access state
- workspace/account resolution
- memberships entre users y accounts
- role lookup para access de client/pm
- profile data agnóstica de locale, como `preferred_locale`

## Current Tree

```text
identity/
  domain/
    aggregates/
      user.rb
      account.rb
      membership.rb
      tenant.rb
      organization.rb
    entities/
      customer_profile.rb
      editor_profile.rb
      operator_profile.rb
    repositories/
      account/contract.rb
      membership/contract.rb
      user/contract.rb
      account_repository.rb
      membership_repository.rb
      user_repository.rb
    value_objects/
      account_id.rb
      email.rb
      role.rb
      user_id.rb
  application/
    queries/
      resolve_workspace_account.rb
    services/
      workspace_resolver.rb
  adapters/
    persistence/
      account/
      membership/
      user/
```

## What Identity Should Be

- Un boundary dedicado para personas, access y workspace selection.
- El lugar donde `User`, `Account` y `Membership` se definen y se mantienen coherentes.
- La source of truth para workspace lookup usada por el shell app.

## What Identity Should Not Be

- Billing logic
- Ordering orchestration
- Catalog o availability rules
- Fulfillment workflows
- Presentation concerns
- UI o controller behavior del shell app

## Regla práctica

- Si el boundary solo resuelve, valida o muta estado, no necesita `presentation` todavía.
- Si empieza a shapear datos para HTML, JSON o view models, ahí sí corresponde separar `presentation`.
- Hoy `identity` no tiene una capa `presentation` propia y no hace falta agregarla por ahora.

## Current Rules

- `WorkspaceResolver` es el entrypoint hacia el shell para client/pm workspace lookup.
- `ResolveWorkspaceAccount` resuelve un workspace account a partir de email + role.
- Los domain contracts se mantienen explícitos y los implementan persistence adapters.
- `User` es el identity root.
- `Account` es el workspace-facing profile.
- `Membership` vincula un user con un account.
- `Role` pertenece al boundary de membership, no al shell.

## Extraction Plan

### Phase 1: Clarify the boundary

- [ ] Revisar cada archivo bajo `identity/` y decidir qué piezas son solo domain, application o persistence.
- [ ] Eliminar naming legacy donde `tenant` / `organization` se superponen con `account`.
- [ ] Hacer explícitas en comments y specs las responsabilidades de `User`, `Account` y `Membership`.

### Phase 2: Stabilize the public API

- [ ] Mantener `WorkspaceResolver` como el único workspace lookup service expuesto al shell.
- [ ] Definir la interfaz mínima tipo SDK que luego consumirá el shell.
- [ ] Documentar qué queries son seguras para exponer hacia afuera.

### Phase 3: Prepare the extraction

- [ ] Separar adapters de domain más limpiamente si algún archivo todavía mezcla ambas concerns.
- [ ] Mover dependencias del shell detrás de contracts.
- [ ] Agregar coverage sobre los public entrypoints antes de mover código afuera.

### Phase 4: Extract to a standalone app

- [ ] Mover el boundary de identity a su propia Rails app.
- [ ] Exponer workspace lookup y profile APIs a través de un SDK o HTTP client.
- [ ] Apuntar el marketplace shell a la nueva identity app.

## Review Questions

- ¿`tenant` todavía significa algo distinto de `account`?
- ¿`organization` debe sobrevivir o ya es legacy noise?
- ¿Qué public calls deben permanecer estables para el shell?
- ¿Qué debería exponer primero el identity SDK: workspace lookup, profile data o role checks?

## Notes

- Este README es el working contract para el refactor de identity.
- Debe actualizarse a medida que refinemos el boundary antes de extraerlo.
