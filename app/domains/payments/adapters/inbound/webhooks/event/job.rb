module Payments
  module Adapters
    module Inbound
      module Webhooks
        module Event
          class Job < ApplicationJob
            MAX_RETRY_ATTEMPTS = Payments::Domain::Policies::RetryPolicy::MAX_ATTEMPTS

            retry_on Payments::Domain::Errors::DemoTransientFailure, wait: 0.seconds, attempts: MAX_RETRY_ATTEMPTS
            retry_on ActiveRecord::Deadlocked, wait: 1.second, attempts: MAX_RETRY_ATTEMPTS

            def perform(payment_webhook_event_id)
              event = Payments::Adapters::Persistence::Webhook::Event::Repository.find_by_id(payment_webhook_event_id)
              return unless event.present?

              Payments::Adapters::Inbound::Webhooks::Event::Handler.(event: event)
            end
          end
        end
      end
    end
  end
end
