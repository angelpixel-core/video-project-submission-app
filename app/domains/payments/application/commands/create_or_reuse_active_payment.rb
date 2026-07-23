module Payments
  module Application
    module Commands
      class CreateOrReuseActivePayment
        def self.call(project:)
          new(project:).call
        end

        def initialize(project:)
          @project = project
        end

        def call
          project.with_lock do
            payment = project.active_payment
            return Core::Result::Success.(data: { payment: payment, attempt: payment.payment_attempts.order(created_at: :desc).first }) if payment.present?

            create_payment_flow!
          end
        end

        private

        attr_reader :project

        def create_payment_flow!
          payment = project.payments.create!(
            status: :pending,
            provider: "fake",
            idempotency_key: SecureRandom.uuid,
            amount_cents: project.total_budget_cents,
            currency: "USD"
          )

          payment.create_payment_method_reference!(
            provider: payment.provider,
            method_type: "card",
            reference: "fake-card-#{payment.idempotency_key}"
          )

          attempt = payment.payment_attempts.create!(
            status: :pending,
            provider: payment.provider,
            idempotency_key: payment.idempotency_key,
            request_payload: payment_request_payload(payment)
          )

          provider_result = Payments::Adapters::Outbound::Gateways::Fake.(payment: payment)

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
      end
    end
  end
end
