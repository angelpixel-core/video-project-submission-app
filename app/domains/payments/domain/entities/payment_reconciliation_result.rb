module Payments
  module Domain
    module Entities
      class PaymentReconciliationResult < ApplicationRecord
        belongs_to :payment, class_name: "Payments::Domain::Aggregates::Payment"

        STATUSES = %w[matched mismatched error].freeze

        before_validation :normalize_status
        before_validation :normalize_snapshot
        before_validation :stamp_reconciled_at

        validates :status, presence: true, inclusion: { in: STATUSES }
        validates :snapshot, presence: true
        validates :reconciled_at, presence: true

        private

        def normalize_status
          self.status = status.to_s.strip.presence || "error"
        end

        def normalize_snapshot
          self.snapshot = (snapshot || {}).to_h
        end

        def stamp_reconciled_at
          self.reconciled_at ||= Time.current
        end
      end
    end
  end
end
