class Notification < ApplicationRecord
  after_save :broadcast_refresh, if: :should_broadcast_refresh?

  belongs_to :project
  belongs_to :account, class_name: "Identity::Domain::Aggregates::Account", foreign_key: :account_id, optional: true

  before_validation :sync_legacy_recipient_columns

  scope :read, -> { where.not(read_at: nil) }
  scope :unread, -> { where(read_at: nil) }
  scope :for_pm, -> { joins(:account).where(accounts: { role: "pm" }) }
  scope :for_client, -> { joins(:account).where(accounts: { role: "client" }) }

  validates :kind, presence: true
  validates :body, presence: true
  validate :recipient_presence

  def mark_as_read!
    update!(read_at: Time.current)
  end

  def recipient
    pm || client
  end

  def pm
    PM.find_by(id: pm_id || account_id) if account&.pm? || pm_id.present? || account_id.present?
  end

  def client
    Client.find_by(id: client_id || account_id) if account&.client? || client_id.present? || account_id.present?
  end

  def pm=(value)
    self.account = value
    self.pm_id = value&.id
    self.client_id = nil
  end

  def client=(value)
    self.account = value
    self.client_id = value&.id
    self.pm_id = nil
  end

  def self.broadcast_refresh_for(recipient, notification: nil)
    return unless recipient.present?

    stream_name = notification_stream_name(recipient)
    return unless stream_name.present?

    ActionCable.server.broadcast(
      stream_name,
      {
        type: "notifications_updated",
        project_id: notification&.project_id,
        kind: notification&.kind
      }
    )
  end

  private

  def self.notification_stream_name(recipient)
    return "pm_notifications" if recipient.respond_to?(:pm?) && recipient.pm?
    return "client_notifications" if recipient.respond_to?(:client?) && recipient.client?

    nil
  end

  def should_broadcast_refresh?
    previously_new_record? || saved_change_to_read_at?
  end

  def broadcast_refresh
    self.class.broadcast_refresh_for(recipient, notification: self)
  end

  def recipient_presence
    if account.blank?
      errors.add(:account, :blank)
    end
  end

  def sync_legacy_recipient_columns
    return if account.blank?

    if account.pm?
      self.pm_id ||= account.id
      self.client_id = nil if client_id.blank?
    elsif account.client?
      self.client_id ||= account.id
      self.pm_id = nil if pm_id.blank?
    end

    self.pm_id ||= pm&.id
    self.client_id ||= client&.id
  end
end
