module Payments
  class PaymentEventHandler
    DEMO_FAILURE_MESSAGE = Payments::Webhook::Event::Handler::DEMO_FAILURE_MESSAGE
    HANDLED_EVENT_TYPES = Payments::Webhook::Event::Handler::HANDLED_EVENT_TYPES

    def self.call(event:)
      Payments::Webhook::Event::Handler.call(event: event)
    end
  end
end
