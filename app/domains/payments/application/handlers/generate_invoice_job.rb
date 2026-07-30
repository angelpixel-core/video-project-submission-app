module Payments
  module Application
    module Handlers
      class GenerateInvoiceJob < ApplicationJob
        def perform(*args)
          Billing::Application::Handlers::GenerateInvoiceJob.perform_now(*args)
        end

        def self.perform_later(*args)
          Billing::Application::Handlers::GenerateInvoiceJob.perform_later(*args)
        end

        # TODO(cleanup): Remove this shim once callers invoke billing directly.
      end
    end
  end
end
