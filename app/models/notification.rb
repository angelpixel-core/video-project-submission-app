class Notification < ApplicationRecord
  after_save :broadcast_refresh, if: :should_broadcast_refresh?

  belongs_to :project
  belongs_to :pm, class_name: "PM"

  scope :read, -> { where.not(read_at: nil) }
  scope :unread, -> { where(read_at: nil) }

  validates :kind, presence: true
  validates :body, presence: true

  def mark_as_read!
    update!(read_at: Time.current)
  end

  def self.broadcast_refresh_for(_pm)
    ActionCable.server.broadcast("pm_notifications", { type: "pm_notifications_updated" })
  end

  private

  def should_broadcast_refresh?
    previously_new_record? || saved_change_to_read_at?
  end

  def broadcast_refresh
    self.class.broadcast_refresh_for(pm)
  end
end
