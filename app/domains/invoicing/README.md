# Invoicing Route Map

`invoicing` es el boundary conceptual para invoice issuance, storage y delivery follow-up.

El código actual todavía vive bajo `app/domains/billing/`, pero el vocabulario del producto ya es `invoicing`.
Este README es el contrato conceptual; `billing/README.md` documenta el nombre físico actual.

## Qué hace hoy

- genera invoices después de payment success
- persiste el artefacto invoice y su metadata
- dispara la entrega de invoice por email
- mantiene el contenido de invoice separado del payment state
- sirve como follow-up boundary para la salida contable del flujo de order

## Qué no debería hacer

- capturar pagos
- decidir fulfillment operativo
- resolver catalog o ordering
- contener UI presentation
- mezclar delivery transport con invoice business rules

## Current Implementation

```text
billing/
  application/
    commands/
      issue_invoice.rb
    handlers/
      generate_invoice_job.rb
      dispatch_invoice_job.rb
```

## Physical vs Conceptual

- `billing` is the current filesystem and namespace surface.
- `invoicing` is the target product vocabulary.
- Keep new docs and public language on `invoicing`, but do not assume a code rename yet.

## Current Rules

- `IssueInvoice` construye y persiste el invoice.
- `GenerateInvoiceJob` corre después de payment success y prepara storage + delivery intent.
- `DispatchInvoiceJob` entrega el invoice ready email.
- Invoice generation only runs after the payment checkpoint.
- Invoice delivery is async and retry-safe.

## Public Contract

La superficie pública conceptual es:

- `Invoicing::Application::Commands::IssueInvoice`
- `Invoicing::Application::Handlers::GenerateInvoiceJob`
- `Invoicing::Application::Handlers::DispatchInvoiceJob`

## Presentation Rule

- `invoicing` no necesita una capa `presentation` propia.
- Si el invoice necesita una vista HTML o una descarga, eso es parte del artefacto o del consumer boundary.
- Este boundary se enfoca en artifact generation and delivery, no en rendering de la app.

## Plan de refinamiento

### Phase 1: Clarify the boundary

- [ ] Separar el concepto `invoicing` del nombre físico `billing` sin perder el contrato actual.
- [ ] Confirmar qué parte es invoice issuance y qué parte es delivery orchestration.
- [ ] Mantener el flow after payment success como un follow-up explícito.

### Phase 2: Stabilize the public API

- [ ] Mantener `IssueInvoice` como el caso principal.
- [ ] Mantener jobs separados para generation y dispatch.
- [ ] Evitar que el boundary absorba payment provider concerns.

### Phase 3: Prepare extraction

- [ ] Mover gradualmente el vocabulario público a `invoicing`.
- [ ] Mantener storage, mail and tax integration behind explicit adapters.
- [ ] Agregar coverage alrededor de idempotency y duplicate delivery.

### Phase 4: Extract to a standalone app

- [ ] Renombrar el boundary físico cuando el contrato esté estable.
- [ ] Conectar invoice issuance con payment success por eventos o job contracts.
- [ ] Mantener el resto del marketplace fuera del detalle contable.

## Review Questions

- ¿`billing` debe seguir existiendo como nombre físico o ya podemos migrar a `invoicing`?
- ¿El delivery de invoice pertenece aquí o a `notifications`?
- ¿Qué contrato mínimo necesita el invoice builder para ser portable?
- ¿El tax integration vive dentro de invoicing o como adapter separado?

## Notes

- Este README usa el nombre de producto `invoicing` aunque la implementación actual siga en `billing`.
- El boundary es post-payment y no participa en capture/confirmation.
- La salida invoice es un artifact durable, no un side effect incidental.
