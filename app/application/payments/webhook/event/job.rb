module Payments
  module Webhook
    module Event
      class Job < ApplicationJob
        retry_on Payments::DemoTransientFailure, wait: 0.seconds, attempts: 2
        retry_on ActiveRecord::Deadlocked, wait: 1.second, attempts: 5

        def perform(payment_webhook_event_id)
          event = Repository.find_by_id(payment_webhook_event_id)
          return unless event.present?

          Payments::PaymentEventHandler.(event: event)
        end
      end
    end
  end
end
