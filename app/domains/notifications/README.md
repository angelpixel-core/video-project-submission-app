# Notifications Route Map

`notifications` es el boundary de delivery orchestration del marketplace.

Su trabajo es recibir una intención de notificación, resolver los channels y disparar la entrega sin conocer la UI del shell ni la lógica de negocio que originó el evento.

## Qué hace hoy

- orquesta la ejecución de delivery channels
- despacha notificaciones a logger, email y futuros channels
- mantiene la entrega separada del dominio que originó el evento
- sirve como boundary transversal para order, payment, fulfillment y delivery events

## Qué no debería hacer

- resolver identity o workspace lookup
- modelar UI presentation
- decidir la lógica de negocio que generó el evento
- contener el contenido de negocio principal de order, payment o fulfillment
- mezclar channel dispatch con controllers del shell

## Current Tree

```text
notifications/
  application/
    notifications/
      service.rb
      dispatcher.rb
      channel/
        logger.rb
        email.rb
```

## What `notifications` Means Here

`notifications` es una capa transversal de delivery, no un boundary de negocio principal.

- recibe una intención de entrega
- elige uno o varios channels
- ejecuta side effects de notificación
- puede crecer hacia email, in-app, logger, push o webhooks

## Current Rules

- `Service` orquesta la entrega y llama al `Dispatcher`.
- `Dispatcher` recorre los channels y los ejecuta.
- `Channel::Logger` es el canal de logging.
- `Channel::Email` encapsula el envío por email.
- El boundary no decide qué evento creó la notificación; solo la entrega.

## Public Contract

La forma pública actual del boundary es pequeña:

- `Notifications::Application::Notifications::Service`
- `Notifications::Application::Notifications::Dispatcher`
- `Notifications::Application::Notifications::Channel::Logger`
- `Notifications::Application::Notifications::Channel::Email`

## Presentation Rule

- `notifications` no necesita una capa `presentation` propia.
- Si un flujo necesita UI presentation, eso vive en el boundary que consume la notificación o en el shell.
- Este boundary se enfoca en delivery plumbing, no en rendering.

## Plan de refinamiento

### Phase 1: Clarify the boundary

- [ ] Revisar si las notificaciones actuales son delivery-only o si alguna necesita convertirse en un boundary de negocio.
- [ ] Confirmar qué eventos entran al boundary y desde qué dominios salen.
- [ ] Mantener `Service` como orchestrator y `Dispatcher` como fanout explícito.

### Phase 2: Stabilize the public API

- [ ] Definir qué payload mínimo necesita cada channel.
- [ ] Mantener logger y email como channels base.
- [ ] Agregar cualquier nuevo channel sin romper el contrato del dispatcher.

### Phase 3: Prepare extraction

- [ ] Separar delivery concerns de cualquier listener o subscriber que viva en otros boundaries.
- [ ] Estabilizar los events de entrada para que el boundary pueda extraerse como app separada.
- [ ] Agregar coverage alrededor del dispatcher y los channels.

### Phase 4: Extract to a standalone app

- [ ] Extraer `notifications` como app dedicada cuando el contrato de delivery esté estable.
- [ ] Conectar los boundaries consumidores por eventos o SDK.
- [ ] Mantener el shell fuera de la entrega concreta.

## Review Questions

- ¿`notifications` debe seguir siendo solo delivery plumbing o también guardar reglas propias?
- ¿Qué events deberían entrar primero al boundary?
- ¿El in-app notification rendering pertenece a `notifications` o al boundary que lo consume?
- ¿Qué channels son parte del contrato público mínimo?

## Notes

- Este README es el working contract para el boundary de `notifications`.
- La capa es transversal y no representa UI presentation.
- El foco inicial está en delivery orchestration, no en la fuente del evento.
