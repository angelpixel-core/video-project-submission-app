class Project < ApplicationRecord
  belongs_to :client
  belongs_to :pm

  has_many :video_type_selections, dependent: :destroy
  has_many :video_types, through: :video_type_selections
  has_many :notifications, dependent: :destroy

  enum :status, { draft: "draft", pending: "pending", in_progress: "in_progress", completed: "completed" }, default: :draft

  validates :name, presence: true, if: :submission_fields_required?
  validates :raw_footage_url, presence: true, if: :submission_fields_required?

  def submit!
    transition_to!(:pending, :draft)
  end

  def accept!
    transition_to!(:in_progress, :pending)
  end

  def complete!
    transition_to!(:completed, :in_progress)
  end

  def submission_fields_required?
    pending? || in_progress? || completed?
  end

  private

  def transition_to!(target_status, expected_status)
    return update!(status: target_status) if public_send("#{expected_status}?")

    errors.add(:status, "must be #{expected_status}")
    raise ActiveRecord::RecordInvalid, self
  end
end
