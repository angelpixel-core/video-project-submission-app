module Payments
  module Adapters
    module Outbound
      module Gateways
        class Fake < Payments::Application::Ports::PaymentGateway
          def self.call(payment:)
            return Core::Result::Failure.(
              message: "Payment amount must be greater than zero.",
              code: :invalid_amount,
              data: { payment_id: payment.id, amount_cents: payment.amount_cents }
            ) if payment.amount_cents <= 0

            provider_reference = "fake-#{payment.idempotency_key}"

            Core::Result::Success.(
              data: {
                provider_reference: provider_reference,
                provider_status: "accepted",
                request_payload: {
                  payment_id: payment.id,
                  project_id: payment.project_id,
                  amount_cents: payment.amount_cents,
                  currency: payment.currency,
                  idempotency_key: payment.idempotency_key
                },
                response_payload: {
                  provider_reference: provider_reference,
                  status: "accepted"
                }
              }
            )
          end
        end
      end
    end
  end
end
