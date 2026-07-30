module Payments
  module Application
    module Handlers
      class DispatchInvoiceJob < ApplicationJob
        def perform(*args)
          Billing::Application::Handlers::DispatchInvoiceJob.perform_now(*args)
        end

        def self.perform_later(*args)
          Billing::Application::Handlers::DispatchInvoiceJob.perform_later(*args)
        end

        # TODO(cleanup): Remove this shim once callers invoke billing directly.
      end
    end
  end
end
