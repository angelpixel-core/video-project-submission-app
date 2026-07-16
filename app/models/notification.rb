class Notification < ApplicationRecord
  belongs_to :project
  belongs_to :pm

  scope :read, -> { where.not(read_at: nil) }
  scope :unread, -> { where(read_at: nil) }

  validates :kind, presence: true
  validates :body, presence: true

  def mark_as_read!
    update!(read_at: Time.current)
  end
end
