# Delivery Route Map

`delivery` es el boundary del final output del marketplace.

Su rol es representar la entrega final del trabajo al cliente y la confirmación de cierre asociada a esa entrega.

## Qué hace hoy

- modela el estado final de la entrega
- expresa cuándo un order ya tiene output listo
- coordina la confirmación de que el artefacto fue entregado
- cierra el ciclo entre fulfillment y customer completion
- puede disparar notificaciones de cierre o confirmación

## Qué no debería hacer

- crear el contenido del video
- capturar pagos
- resolver catalog o ordering
- administrar el trabajo operativo interno
- duplicar la lógica de notifications
- mezclar UI presentation con business state

## Current Surface

Hoy el concepto vive repartido entre otros boundaries, principalmente en el estado `delivery_status` del order y en la handoff posterior a fulfillment.

```text
ordering/
  domain/
    value_objects/
      delivery_status.rb
    aggregates/
      order.rb
```

## Current Rules

- `delivery` representa el output final, no la producción.
- `fulfillment` entrega el trabajo listo para salida.
- `notifications` puede avisar sobre cierre o entrega completada.
- `ordering` conserva el delivery status como parte del lifecycle agregado mientras el boundary físico no exista.

## Public Contract

La forma pública conceptual todavía no está extraída, pero el boundary apunta a conceptos como:

- delivery readiness
- delivery confirmation
- final artifact handoff
- closure notification trigger

## Presentation Rule

- `delivery` no necesita una capa `presentation` propia.
- Si hay una pantalla o response shape para la entrega, eso vive en el consumer boundary.
- Aquí solo importa el estado y la transición de entrega final.

## Plan de refinamiento

### Phase 1: Clarify the boundary

- [ ] Definir si `delivery` seguirá dentro de `ordering` por ahora o si ya necesita carpeta propia.
- [ ] Separar delivery final de fulfillment operativo.
- [ ] Confirmar qué notifications son parte del cierre de delivery.

### Phase 2: Stabilize the public API

- [ ] Mantener delivery status y confirmation semantics explícitos.
- [ ] Evitar que delivery se confunda con shipping o production.
- [ ] Definir el payload mínimo para entrega y cierre.

### Phase 3: Prepare extraction

- [ ] Extraer el concepto a un boundary físico propio cuando el contrato esté claro.
- [ ] Conectar con `fulfillment`, `invoicing` y `notifications` por interfaces simples.
- [ ] Agregar coverage para readiness, confirmation y closure.

### Phase 4: Extract to a standalone app

- [ ] Crear el boundary físico `delivery` cuando ya no dependa del lifecycle interno de `ordering`.
- [ ] Mantener el shell como consumidor de estado, no como dueño de la entrega.
- [ ] Aislar la confirmación final como una etapa propia del flujo.

## Review Questions

- ¿`delivery` debe ser un boundary aparte ya mismo o seguir como parte del order aggregate?
- ¿La entrega final del video requiere storage propio o solo status y notifications?
- ¿Qué parte del cierre pertenece a fulfillment y qué parte a delivery?
- ¿Qué eventos deberían disparar la confirmation final?

## Notes

- Este README documenta el target boundary, aunque el código aún no lo haya extraído.
- `delivery` es la salida final del flujo, no la producción interna.
- El estado `delivery_status` en `ordering` es el puente temporal actual.
