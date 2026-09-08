# Catalog Route Map

`catalog` es la capa de oferta y publicación del marketplace.

No es inventory, no es ordering y no es capacity. Su trabajo es decidir qué se expone, cómo se agrupa y cómo se presenta la oferta visible para el storefront.

## Qué hace hoy

- agrupa `Offer` y `OfferVariant`
- publica catálogo visible para client y admin
- aplica `VisibilityPolicy`, `AvailabilityPolicy`, `PricingPolicy` y `SelectionPolicy`
- consulta `Capacity` para availability
- expone queries y commands para leer y administrar video types
- shapea la salida para UI mediante `presentation`

## Qué no debería hacer

- reservar capacity
- confirmar o cancelar orders
- conocer controllers del shell fuera de los adapters de entrada
- decidir workflow de checkout
- contener lógica de identity o workspace resolution

## Current Tree

```text
catalog/
  domain/
    aggregates/
      offer.rb
      offering.rb
    entities/
      offer_variant.rb
      offering_variant.rb
      video_type.rb
    policies/
      availability_policy.rb
        rule_set.rb
        rules/
          availability_rule.rb
          offer_rule.rb
          resource_rule.rb
          variant_rule.rb
      pricing_policy.rb
      selection_policy.rb
      visibility_policy.rb
    repositories/
      offer_repository.rb
    value_objects/
      availability.rb
      currency.rb
      duration.rb
      offer_id.rb
      offer_name.rb
      price.rb
      selection_quantity.rb
  application/
    commands/
      create_video_type.rb
      publish_video_type.rb
      retire_video_type.rb
      update_video_type.rb
    dto/
      video_type_dto.rb
    ports/
      capacity_gateway.rb
    queries/
      find_video_type.rb
      list_admin_video_types.rb
      list_public_video_types.rb
  adapters/
    inbound/
      http/
        admin_video_types_controller.rb
        public_catalog_controller.rb
    outbound/
      capacity/
        capacity_client.rb
    persistence/
      active_record_offer_repository.rb
      video_type_record.rb
  presentation/
    (implemented today as `app/presenters/catalog/`)
```

## Physical Presentation Layer

- `app/presenters/catalog/offer_catalog_presenter.rb`
- `app/presenters/orders/order_form_presenter.rb` is a separate presentation example for ordering.

## What `presentation` Means Here

`presentation` is the layer that shapes domain/application data for the edge of the app.

- HTML view models
- grouped catalog output
- labels, counts, and empty states
- data formatting that does not belong in domain rules

## Regla práctica

- Si el boundary shapea datos para HTML, JSON o view models, corresponde `presentation`.
- Si solo decide reglas, consulta capacidad o muta estado, no debe ir a `presentation`.
- En `catalog` sí existe hoy una capa `presentation`, aunque su ubicación física actual sea `app/presenters/`.

## Current Rules

- `ListPublicVideoTypes` is the public storefront query.
- `ListAdminVideoTypes` is the admin-facing query.
- `FindVideoType` resolves one offer variant for edge rendering.
- `OfferCatalogPresenter` groups variants by offer and sorts them for display.
- `CapacityClient` is the outbound bridge to the capacity boundary.
- `AvailabilityPolicy` is the catalog-level policy that asks capacity whether something can be offered.

## Policy vs Workflow

- `VisibilityPolicy` and `AvailabilityPolicy` are policies.
- `CreateVideoType`, `UpdateVideoType`, `PublishVideoType`, and `RetireVideoType` are workflows/commands.
- `OfferCatalogPresenter` is presentation, not domain.

## Public Contract

The current public contract for `catalog` is the set of entrypoints the shell and ordering already use:

- `Catalog::Application::Queries::ListPublicVideoTypes`
- `Catalog::Application::Queries::FindVideoType`
- `Catalog::OfferCatalogPresenter`
- `Catalog::Adapters::Inbound::Http::PublicCatalogController`
- `Catalog::Adapters::Inbound::Http::AdminVideoTypesController`

## Plan de refinamiento

### Phase 1: Clarify the boundary

- [ ] Review each file under `catalog/` and separate domain, application, adapters, and presentation concerns.
- [ ] Decide whether any logic currently inside `domain/policies` should become a workflow or remain a policy.
- [ ] Keep `presentation` explicit and use `app/presenters/catalog/` as the physical home for view shaping.

### Phase 2: Stabilize the public API

- [ ] Keep public catalog queries stable for the storefront.
- [ ] Keep admin commands stable for catalogue maintenance.
- [ ] Reduce direct knowledge of `Capacity` to the smallest possible contract.

### Phase 3: Prepare extraction

- [ ] Replace the temporary `CapacityGateway` / `CapacityClient` bridge with a clearer service boundary if needed.
- [ ] Move any remaining UI shaping out of domain code and into `presentation`.
- [ ] Add coverage around public queries and presenter output before extraction.

### Phase 4: Extract to a standalone app

- [ ] Extract `catalog` as its own Rails app when the public contract is stable.
- [ ] Expose catalog data to the storefront through SDK or HTTP.
- [ ] Keep `presentation` in the catalog app, while the storefront only consumes its output.

## Review Questions

- ¿`presentation` es el término correcto para esta capa en el catálogo?
- ¿Qué lógica de availability debe permanecer como policy y cuál debería moverse a `Capacity`?
- ¿Qué parte del catálogo consume el storefront directamente y qué parte debería quedar solo para admin?
- ¿`OfferCatalogPresenter` debe seguir siendo un presenter de catálogo o conviene moverlo a una capa `presentation` más amplia?

## Notes

- Este README es el working contract para el boundary de `catalog`.
- `presentation` es el nombre arquitectónico correcto; hoy su implementación física está en `app/presenters/`.
- `catalog` sigue siendo el layer de oferta visible, no el storage de stock.
