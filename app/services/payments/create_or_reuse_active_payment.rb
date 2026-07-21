module Payments
  class CreateOrReuseActivePayment
    def initialize(project:)
      @project = project
    end

    def call
      project.with_lock do
        payment = project.payments.active.order(created_at: :desc).first
        payment ||= create_payment!
        ensure_payment_attempt!(payment)
        payment
      end
    end

    private

    attr_reader :project

    def create_payment!
      project.payments.create!(
        status: :pending,
        provider: "fake",
        idempotency_key: SecureRandom.uuid,
        amount_cents: project.total_budget_cents,
        currency: "USD"
      )
    end

    def ensure_payment_attempt!(payment)
      payment.payment_attempts.find_or_create_by!(idempotency_key: payment.idempotency_key) do |attempt|
        attempt.status = :pending
        attempt.provider = payment.provider
        attempt.provider_reference = payment.provider_reference
        attempt.request_payload = payment_request_payload(payment)
        attempt.response_payload = { status: payment.status, provider: payment.provider }
      end
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
