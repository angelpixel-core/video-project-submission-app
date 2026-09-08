# Capacity Route Map

`capacity` es el nombre técnico de este package por ahora.

Conceptualmente, este boundary modela `inventory`: un sistema agnóstico que guarda recursos, unidades, reservas y reglas de disponibilidad sin conocer el storefront.

En el storefront vertical, eso se traduce como `availability`.

## Qué hace hoy

- calcula disponibilidad a partir de órdenes activas y reservas activas
- reserva, confirma, libera y expira capacity
- expone queries para leer availability
- publica eventos de ciclo de vida de capacity
- consume datos de `catalog`, `ordering` e `identity` para resolver la regla de negocio

## Qué no debería hacer

- decidir cómo se muestra la oferta en el storefront
- conocer detalles de UI o controllers del shell
- decidir pricing, copy o presentación de catálogo
- contener lógica de ordering más allá de la reserva de capacity
- mezclar reglas de availability con rendering o navegación

## Regla práctica

- Si el boundary solo calcula availability, reserva o expira recursos, no necesita `presentation` todavía.
- Si en el futuro shapea datos para UI, entonces sí conviene separar una capa `presentation`.
- Hoy `capacity` no tiene una capa `presentation` propia y no hace falta agregarla por ahora.

## Current Tree

```text
capacity/
  domain/
    aggregates/
      production_capacity.rb
    entities/
      capacity_period.rb
      capacity_reservation.rb
    errors/
      invalid_reservation_transition.rb
    events/
      capacity_committed.rb
      capacity_reservation_expired.rb
      capacity_released.rb
      capacity_reserved.rb
      capacity_unavailable.rb
    policies/
      capacity_calculation_policy.rb
      reservation_expiration_policy.rb
      workload_estimation_policy.rb
    repositories/
      capacity_repository.rb
      capacity_reservation/
        contract.rb
    value_objects/
      capacity_id.rb
      capacity_units.rb
      reservation_expiration.rb
      reservation_id.rb
      reservation_status.rb
  application/
    commands/
      commit_capacity.rb
      expire_capacity_reservation.rb
      release_capacity.rb
      reserve_capacity.rb
    dto/
      capacity_dto.rb
    ports/
      clock.rb
      workload_source.rb
    queries/
      check_capacity.rb
  adapters/
    inbound/
      event_consumers/
        project_capacity_consumer.rb
      scheduled_jobs/
        check_capacity_job.rb
    outbound/
      catalog/
        catalog_reader.rb
    persistence/
      active_record_capacity_repository.rb
      capacity_record.rb
      capacity_reservation/
        mapper.rb
        capacity_reservation_record.rb
        repository.rb
```

## Qué es `inventory`

`inventory` es el concepto más agnóstico del sistema.

- no sabe quién está mirando
- no sabe si vende videos, zapatillas o cualquier otra cosa
- solo administra recursos, unidades y disponibilidad

## Qué es `availability`

`availability` es la traducción de negocio que ve el storefront.

- responde si algo se puede ofrecer o reservar
- puede variar por marketplace o contexto vertical
- es la capa semántica visible para el negocio

## Reglas actuales

- `CapacityCalculationPolicy` es la policy de lectura de availability.
- `CheckCapacity` es la query pública para consultar disponibilidad.
- `ReserveCapacity`, `CommitCapacity`, `ReleaseCapacity` y `ExpireCapacityReservation` son commands de workflow.
- `ProductionCapacity` concentra el cálculo simple de unidades disponibles.
- Los adapters de `catalog` y `ordering` conectan este boundary con el resto del sistema.

## Cómo decidir policy vs workflow

- Si solo responde “¿se puede?” o “¿cuánto queda?” -> `policy`.
- Si cambia estado o coordina pasos -> `workflow` / `command`.
- Si emite eventos o persiste cambios -> nunca es solo `policy`.

## Plan de refinamiento

### Phase 1: Clarify the boundary

- [ ] Revisar si algún archivo mezcla `inventory`, `capacity` y `availability` sin una frontera clara.
- [ ] Separar lectura de availability de la escritura de reservas.
- [ ] Confirmar que la nomenclatura del código siga siendo `capacity` mientras el concepto se documenta como `inventory`.

### Phase 2: Stabilize the public API

- [ ] Definir qué métodos son realmente públicos para el storefront y para `ordering`.
- [ ] Mantener `CheckCapacity` como query de lectura.
- [ ] Mantener los commands de reserva como la única vía de cambio de estado.

### Phase 3: Prepare extraction

- [ ] Aislar los contracts que el shell o el marketplace van a consumir.
- [ ] Revisar adapters de `catalog` y `ordering` para que dependan del boundary y no de detalles internos.
- [ ] Agregar coverage alrededor de los entrypoints públicos antes de mover el boundary fuera del monorepo.

### Phase 4: Extract to a standalone app

- [ ] Extraer `capacity` como app separada cuando el contrato público esté estable.
- [ ] Exponer availability/reservation por SDK o HTTP client.
- [ ] Mantener `availability` como vocabulario del storefront y `inventory` como concepto agnóstico.

## Review Questions

- ¿`capacity` sigue siendo el mejor nombre técnico mientras se extrae?
- ¿Qué parte debe quedarse como `policy` y qué parte como `command`?
- ¿Qué contrato público necesita `ordering` primero?
- ¿El storefront debería consumir `availability` o solo el `inventory` SDK?

## Notes

- Este README es el working contract del boundary de `capacity`.
- El nombre técnico puede quedarse en `capacity` aunque el concepto general sea `inventory`.
- La presentación de negocio para el storefront debe hablar de `availability`.
