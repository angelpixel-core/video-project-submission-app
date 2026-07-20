class Project < ApplicationRecord
  include AASM

  belongs_to :client
  belongs_to :pm, class_name: "PM"

  has_many :video_type_selections, dependent: :destroy
  has_many :video_types, through: :video_type_selections
  has_many :notifications, dependent: :destroy
  has_many :comments, dependent: :destroy

  scope :for_pm_table, lambda {
    left_outer_joins(video_type_selections: :video_type)
      .select(<<~SQL.squish)
        projects.*,
        COALESCE(SUM(video_type_selections.quantity * video_types.price_cents), 0) AS total_budget_cents
      SQL
      .group("projects.id")
  }

  aasm column: :status do
    state :draft, initial: true
    state :pending
    state :in_progress
    state :completed

    event :submit do
      transitions from: :draft, to: :pending
    end

    event :accept do
      transitions from: :pending, to: :in_progress
    end

    event :complete do
      transitions from: :in_progress, to: :completed
    end
  end

  validates :name, presence: true, if: :submitted?
  validates :raw_footage_url, presence: true, if: :submitted?
  validate :youtube_url_must_be_valid, if: -> { youtube_url.present? }

  def total_budget_cents
    return self[:total_budget_cents] if has_attribute?(:total_budget_cents) && self[:total_budget_cents].present?

    video_type_selections.includes(:video_type).sum do |selection|
      selection.quantity * selection.video_type.price_cents
    end
  end

  def submitted?
    pending? || in_progress? || completed?
  end

  private

  def youtube_url_must_be_valid
    errors.add(:youtube_url, "must be a valid YouTube URL") unless YoutubeUrlParser.valid?(youtube_url)
  end
end
