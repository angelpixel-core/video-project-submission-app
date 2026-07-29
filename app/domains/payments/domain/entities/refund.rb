module Payments
  module Domain
    module Entities
      class Refund < ApplicationRecord
        belongs_to :payment, class_name: "Payments::Domain::Aggregates::Payment"
        belongs_to :payment_method_reference, class_name: "Payments::Domain::Entities::PaymentMethodReference"

        STATUSES = %w[pending processed failed].freeze

        scope :pending, -> { where(status: "pending") }
        scope :processed, -> { where(status: "processed") }
        scope :failed, -> { where(status: "failed") }

        before_validation :normalize_provider
        before_validation :normalize_status

        validates :status, presence: true, inclusion: { in: STATUSES }
        validates :provider, presence: true
        validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
        validates :provider_reference, uniqueness: true, allow_nil: true
        validate :payment_method_reference_belongs_to_payment

        private

        def normalize_provider
          self.provider = provider.to_s.strip.presence || "fake"
        end

        def normalize_status
          self.status = status.to_s.strip.downcase.presence || "pending"
        end

        def payment_method_reference_belongs_to_payment
          return if payment_method_reference.blank? || payment_method_reference.payment_id == payment_id

          errors.add(:payment_method_reference, "must belong to the same payment")
        end
      end
    end
  end
end
