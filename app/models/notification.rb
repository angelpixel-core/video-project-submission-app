class Notification < ApplicationRecord
  after_save :broadcast_refresh, if: :should_broadcast_refresh?

  belongs_to :project
  belongs_to :pm, class_name: "PM", optional: true
  belongs_to :client, optional: true

  scope :read, -> { where.not(read_at: nil) }
  scope :unread, -> { where(read_at: nil) }
  scope :for_pm, -> { where.not(pm_id: nil) }
  scope :for_client, -> { where.not(client_id: nil) }

  validates :kind, presence: true
  validates :body, presence: true
  validate :recipient_presence

  def mark_as_read!
    update!(read_at: Time.current)
  end

  def self.broadcast_refresh_for(recipient)
    return unless recipient.present?

    stream_name = notification_stream_name(recipient)
    return unless stream_name.present?

    ActionCable.server.broadcast(stream_name, { type: "notifications_updated" })
  end

  private

  def recipient
    pm || client
  end

  def self.notification_stream_name(recipient)
    case recipient
    when PM
      "pm_notifications"
    when Client
      "client_notifications"
    end
  end

  def should_broadcast_refresh?
    previously_new_record? || saved_change_to_read_at?
  end

  def broadcast_refresh
    self.class.broadcast_refresh_for(recipient)
  end

  def recipient_presence
    if pm.blank? && client.blank?
      errors.add(:pm, :blank)
      errors.add(:client, :blank)
    end

    if pm.present? && client.present?
      errors.add(:base, "Notification recipient must be exclusive")
    end
  end
end
