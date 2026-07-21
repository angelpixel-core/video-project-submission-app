class PaymentWebhookEvent < ApplicationRecord
  STATUSES = %w[received processed failed].freeze

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
