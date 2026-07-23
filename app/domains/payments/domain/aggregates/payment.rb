module Payments
  module Domain
    module Aggregates
      class Payment < ApplicationRecord
        belongs_to :project
        has_one_attached :invoice_document
        has_many :payment_attempts, class_name: "Payments::Domain::Entities::PaymentAttempt", dependent: :destroy
        has_one :payment_method_reference, class_name: "Payments::Domain::Entities::PaymentMethodReference", dependent: :destroy
        has_many :refunds, class_name: "Payments::Domain::Entities::Refund", dependent: :destroy
        has_many :payment_webhook_events, class_name: "Payments::Domain::Entities::PaymentWebhookEvent", dependent: :nullify
        has_many :payment_notification_intents, class_name: "Payments::Domain::Entities::PaymentNotificationIntent", dependent: :destroy
        has_many :payment_invoice_delivery_intents, class_name: "Payments::Domain::Entities::PaymentInvoiceDeliveryIntent", dependent: :destroy

        ACTIVE_STATUSES = %w[pending processing].freeze
        TERMINAL_STATUSES = %w[succeeded failed canceled].freeze
        STATUSES = (ACTIVE_STATUSES + TERMINAL_STATUSES).freeze

        before_validation :normalize_provider
        before_validation :normalize_currency

        after_commit :enqueue_invoice_generation_job, on: :update

        validates :status, presence: true, inclusion: { in: STATUSES }
        validates :provider, presence: true
        validates :idempotency_key, presence: true, uniqueness: true
        validates :amount_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
        validates :currency, presence: true
        validates :provider_reference, uniqueness: true, allow_nil: true
        validate :only_one_active_payment_per_project, on: :create

        scope :active, -> { where(status: ACTIVE_STATUSES) }

        def active?
          ACTIVE_STATUSES.include?(status)
        end

        def succeeded?
          status == "succeeded"
        end

        def webhook_events
          associated_events = payment_webhook_events.order(created_at: :desc).to_a
          legacy_events = Payments::Domain::Entities::PaymentWebhookEvent.where(provider: provider).select { |event| event.references_payment?(self) }

          (associated_events + legacy_events).uniq(&:id).sort_by(&:created_at).reverse
        end

        def invoice_generated?
          invoice_generated_at.present?
        end

        def current_payment_method_type
          payment_method_reference&.method_type_object
        end

        private

        def normalize_provider
          self.provider = provider.to_s.strip.presence || "fake"
        end

        def normalize_currency
          self.currency = currency.to_s.strip.upcase.presence || "USD"
        end

        def enqueue_invoice_generation_job
          return unless saved_change_to_status? && succeeded?

          Payments::Application::Handlers::GenerateInvoiceJob.perform_later(id)
        end

        def only_one_active_payment_per_project
          return unless active?
          return unless project&.payments&.active&.exists?

          errors.add(:base, "Project already has an active payment")
        end
      end
    end
  end
end
