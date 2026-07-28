module Payments
  module Adapters
    module Outbound
      module Gateways
        class Stripe < Payments::Application::Ports::Gateway
          def self.call(payment:)
            fake_result(payment:, provider: "stripe")
          end

          def self.fake_result(payment:, provider:)
            provider_reference = "#{provider}-#{payment.idempotency_key}"

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
