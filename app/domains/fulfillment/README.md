# Fulfillment Route Map

`fulfillment` es el boundary de trabajo operativo sobre una order.

Su rol hoy es el puente entre la intención del cliente y la ejecución interna: prepara el draft, persiste cambios, valida la submission y dispara la transición hacia payment y follow-up work.

## Qué hace hoy

- crea drafts de order para el workspace adecuado
- autosavea cambios antes de finalizar
- procesa la submission final de una order
- coordina acciones operativas como accept, complete, cancel y reopen
- usa el repository contract para leer y mutar el estado de order
- actúa como bridge temporal hacia `ordering` y `payments`

## Qué no debería hacer

- definir catálogo u ofertas
- resolver identity o workspace lookup por su cuenta
- contener payment provider logic como preocupación primaria
- modelar delivery final
- mezclar UI presentation con la workflow operativa
- duplicar la lógica de `ordering` para listing o read models

## Current Tree

```text
fulfillment/
  domain/
    repositories/
      order/
        contract.rb
  application/
    commands/
      autosave_draft_order.rb
      create_draft_order.rb
      process_order_action.rb
      submit_order.rb
      update_order.rb
```

## Current Rules

- `CreateDraftOrder` obtiene o crea el draft para el owner correcto.
- `AutosaveDraftOrder` persiste edición parcial sin salir del draft.
- `SubmitOrder` materializa la submission y hoy todavía puentea hacia payment.
- `UpdateOrder` decide entre autosave y submit según `finalize`.
- `ProcessOrderAction` concentra las acciones operativas del lifecycle.
- `Order::Contract` define el shape mínimo del repository esperado.

## Public Contract

La superficie pública actual es:

- `Fulfillment::Application::Commands::CreateDraftOrder`
- `Fulfillment::Application::Commands::AutosaveDraftOrder`
- `Fulfillment::Application::Commands::SubmitOrder`
- `Fulfillment::Application::Commands::UpdateOrder`
- `Fulfillment::Application::Commands::ProcessOrderAction`
- `Fulfillment::Domain::Repositories::Order::Contract`

## Workflow Boundaries

- `create_draft` abre el draft inicial.
- `autosave` mantiene el work-in-progress seguro.
- `submit` valida y entrega la order a la siguiente etapa.
- `process_action` gobierna el lifecycle operativo posterior.
- `ordering` debe quedarse con el workflow de submission de negocio.
- `fulfillment` debe quedarse con la coordinación operativa y la mutación del estado de trabajo.

## Presentation Rule

- `fulfillment` no necesita una capa `presentation` propia.
- Si hay shapeo de HTML o JSON, eso vive en el boundary consumidor o en el shell.
- Aquí solo hay coordinación operativa y repository-driven mutations.

## Plan de refinamiento

### Phase 1: Clarify the boundary

- [ ] Separar con más nitidez qué parte de `submit` sigue en `fulfillment` y qué parte debe vivir en `ordering`.
- [ ] Confirmar si `ProcessOrderAction` es parte estable del boundary o un bridge transitorio.
- [ ] Mantener el repository contract pequeño y explícito.

### Phase 2: Stabilize the public API

- [ ] Mantener los comandos actuales como contract básico.
- [ ] Reducir el acoplamiento con payment a la mínima superficie necesaria.
- [ ] Evitar que el boundary crezca con responsabilidades de delivery o invoicing.

### Phase 3: Prepare extraction

- [ ] Aislar la workflow operativa del shell.
- [ ] Documentar claramente los inputs y outputs de cada command.
- [ ] Agregar coverage alrededor de draft, submit y actions.

### Phase 4: Extract to a standalone app

- [ ] Extraer `fulfillment` cuando el workflow operativo esté estable.
- [ ] Conectar con `ordering`, `payments`, `invoicing` y `notifications` por contratos explícitos.
- [ ] Mantener el shell como consumidor, no como dueño del flujo.

## Review Questions

- ¿`SubmitOrder` debe quedarse aquí o moverse completamente a `ordering`?
- ¿Qué parte del lifecycle operativo es realmente fulfillment y qué parte es submission?
- ¿El repository contract actual cubre solo lo necesario o ya expone demasiado?
- ¿Hay alguna future responsibility de delivery que deba salir de este boundary?

## Notes

- Este README documenta el bridge actual, no necesariamente el estado final.
- `fulfillment` hoy es el boundary operativo más cercano al estado real de la order.
- La separación fina entre `ordering` y `fulfillment` sigue siendo el principal tema abierto.
