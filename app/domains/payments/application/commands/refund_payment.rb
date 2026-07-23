module Payments
  module Application
    module Commands
      class RefundPayment
        def self.call(payment:, amount_cents:, reason: nil)
          new(payment:, amount_cents:, reason:).call
        end

        def initialize(payment:, amount_cents:, reason: nil)
          @payment = payment
          @amount_cents = amount_cents.to_i
          @reason = reason
        end

        def call
          return failure("Payment cannot be refunded.", :not_refundable) unless Payments::Domain::Policies::RefundPolicy.refundable?(payment)
          return failure("Payment method reference missing.", :missing_payment_method) if payment.payment_method_reference.blank?

          refund = payment.refunds.create!(
            payment_method_reference: payment.payment_method_reference,
            provider: payment.provider,
            provider_reference: "refund-#{SecureRandom.uuid}",
            status: :processed,
            amount_cents: amount_cents,
            reason: reason,
            processed_at: Time.current
          )

          Core::Result::Success.(data: { payment: payment, refund: refund, event: Payments::Domain::Events::PaymentRefunded.new(payment: payment) })
        end

        private

        attr_reader :payment, :amount_cents, :reason

        def failure(message, code)
          Core::Result::Failure.(message: message, code: code, data: { payment_id: payment.id })
        end
      end
    end
  end
end
