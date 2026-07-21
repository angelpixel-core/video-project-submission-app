module Payments
  class ProcessWebhookEventJob < ApplicationJob
    def perform(payment_webhook_event_id)
      event = PaymentWebhookEvent.find_by(id: payment_webhook_event_id)
      return unless event.present?

      Payments::PaymentEventHandler.(event: event)
    end
  end
end
