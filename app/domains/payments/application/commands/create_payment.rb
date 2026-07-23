module Payments
  module Application
    module Commands
      class CreatePayment
        def self.call(project:, provider: "fake", payment_method_type: "card")
          new(project:, provider:, payment_method_type:).call
        end

        def initialize(project:, provider: "fake", payment_method_type: "card")
          @project = project
          @provider = provider.to_s.strip.presence || "fake"
          @payment_method_type = payment_method_type.to_s.strip.presence || "card"
        end

        def call
          project.with_lock do
            payment = Payments::Domain::Repositories::PaymentRepository.find_active_by_project(project)
            return Core::Result::Success.(data: { payment: payment, attempt: payment.payment_attempts.order(created_at: :desc).first }) if payment.present?

            create_payment_flow!
          end
        end

        private

        attr_reader :project

        def create_payment_flow!
          payment = project.payments.create!(
            status: :pending,
            provider: provider_name,
            idempotency_key: SecureRandom.uuid,
            amount_cents: project.total_budget_cents,
            currency: "USD"
          )

          payment.create_payment_method_reference!(
            provider: payment.provider,
            method_type: payment_method_type,
            reference: "#{payment.provider}-#{payment.idempotency_key}"
          )

          attempt = payment.payment_attempts.create!(
            status: :pending,
            provider: payment.provider,
            idempotency_key: payment.idempotency_key,
            request_payload: payment_request_payload(payment)
          )

          provider_result = payment_gateway_for(payment).call(payment: payment)

          return handle_provider_failure(payment:, attempt:, provider_result:) if provider_result.failure?

          payment.update!(
            status: :processing,
            provider_reference: provider_result.data.fetch(:provider_reference)
          )

          attempt.update!(
            status: :submitted,
            provider_reference: provider_result.data.fetch(:provider_reference),
            response_payload: provider_result.data.fetch(:response_payload)
          )

          Core::Result::Success.(data: { payment: payment, attempt: attempt, provider_result: provider_result })
        end

        def handle_provider_failure(payment:, attempt:, provider_result:)
          payment.update!(
            status: :failed,
            failed_at: Time.current
          )

          attempt.update!(
            status: :failed,
            error_message: provider_result.message,
            response_payload: provider_result.data
          )

          Core::Result::Failure.(
            message: provider_result.message,
            code: provider_result.code,
            data: provider_result.data.merge(payment_id: payment.id)
          )
        end

        def payment_request_payload(payment)
          {
            project_id: payment.project_id,
            amount_cents: payment.amount_cents,
            currency: payment.currency,
            status: payment.status
          }
        end

        def provider_name
          provider
        end

        def payment_gateway_for(payment)
          case payment.provider
          when "stripe"
            Payments::Adapters::Outbound::Gateways::StripePaymentGateway
          when "mercadopago"
            Payments::Adapters::Outbound::Gateways::MercadoPagoPaymentGateway
          else
            Payments::Adapters::Outbound::Gateways::Fake
          end
        end

        attr_reader :provider, :payment_method_type
      end
    end
  end
end
