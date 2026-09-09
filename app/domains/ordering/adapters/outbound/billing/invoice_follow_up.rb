module Ordering
  module Adapters
    module Outbound
      module Billing
        class InvoiceFollowUp < Ordering::Application::Ports::InvoicingPort
          def self.call(payment:)
            # TODO(cleanup): Replace with the standalone invoicing contract.
            ::Billing::Application::Handlers::GenerateInvoiceJob.perform_later(payment.id)
          end
        end
      end
    end
  end
end
