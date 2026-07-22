class PaymentWebhookEvent < ApplicationRecord
  STATUSES = %w[received processed failed].freeze

  belongs_to :payment, optional: true
  belongs_to :project, optional: true

  before_validation :normalize_provider
  before_validation :normalize_status
  before_validation :normalize_payload
  before_validation :stamp_received_at, on: :create

  validates :provider, presence: true
  validates :provider_event_id, presence: true, uniqueness: { scope: :provider }
  validates :event_type, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :payload, presence: true
  validates :received_at, presence: true

  def references_payment?(payment)
    data = payload.to_h.fetch("data", {}).to_h
    data["payment_id"].to_s == payment.id.to_s || data["provider_reference"].to_s == payment.provider_reference.to_s
  end

  def applied?
    status == "processed"
  end

  def record_processing_attempt!
    now = Time.current
    increment!(:processing_attempts_count)
    update!(last_attempted_at: now)
  end

  def mark_failed!(message)
    update!(
      status: :failed,
      error_message: message,
      last_failure_at: Time.current,
      last_failure_message: message
    )
  end

  def mark_processed!
    update!(status: :processed, processed_at: Time.current, error_message: nil)
  end

  def synchronize_payment_context!(payment)
    return unless payment.present?

    update!(payment: payment, project: payment.project) if self.payment_id != payment.id || self.project_id != payment.project_id
  end

  private

  def normalize_provider
    self.provider = provider.to_s.strip.downcase
  end

  def normalize_status
    self.status = status.to_s.presence || "received"
  end

  def normalize_payload
    self.payload = (payload || {}).to_h
  end

  def stamp_received_at
    self.received_at ||= Time.current
  end
end
