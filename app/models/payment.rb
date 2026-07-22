class Payment < ApplicationRecord
  belongs_to :project
  has_many :payment_attempts, dependent: :destroy
  has_many :payment_webhook_events, dependent: :nullify
  has_many :payment_notification_intents, dependent: :destroy

  ACTIVE_STATUSES = %w[pending processing].freeze
  TERMINAL_STATUSES = %w[succeeded failed canceled].freeze
  STATUSES = (ACTIVE_STATUSES + TERMINAL_STATUSES).freeze

  before_validation :normalize_provider
  before_validation :normalize_currency

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

  def webhook_events
    associated_events = payment_webhook_events.order(created_at: :desc).to_a
    legacy_events = PaymentWebhookEvent.where(provider: provider).select { |event| event.references_payment?(self) }

    (associated_events + legacy_events).uniq(&:id).sort_by(&:created_at).reverse
  end

  private

  def normalize_provider
    self.provider = provider.to_s.strip.presence || "fake"
  end

  def normalize_currency
    self.currency = currency.to_s.strip.upcase.presence || "USD"
  end

  def only_one_active_payment_per_project
    return unless active?
    return unless project&.payments&.active&.exists?

    errors.add(:base, "Project already has an active payment")
  end
end
