class Project < ApplicationRecord
  include AASM

  belongs_to :client
  belongs_to :pm, class_name: "PM"

  has_many :video_type_selections, dependent: :destroy
  has_many :video_types, through: :video_type_selections
  has_many :payments, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :comments, dependent: :destroy

  before_validation :sync_raw_footage_metadata

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

  def total_budget_cents
    return self[:total_budget_cents] if has_attribute?(:total_budget_cents) && self[:total_budget_cents].present?

    video_type_selections.includes(:video_type).sum do |selection|
      selection.quantity * selection.video_type.price_cents
    end
  end

  def submitted?
    pending? || in_progress? || completed?
  end

  def active_payment
    payments.active.order(created_at: :desc).first
  end

  def raw_footage_metadata_hash
    self[:raw_footage_metadata].presence || {}
  end

  def raw_footage_provider
    raw_footage_metadata_hash["provider"]
  end

  def raw_footage_embed_url(parent_host: nil)
    embed_url = raw_footage_metadata_hash["embed_url"]
    return embed_url unless raw_footage_provider == "twitch"

    embed_url&.gsub("{parent}", parent_host.presence || "localhost")
  end

  def raw_footage_social_preview?
    %w[instagram tiktok].include?(raw_footage_provider)
  end

  def raw_footage_thumbnail_url
    raw_footage_metadata_hash["thumbnail_url"]
  end

  def raw_footage_aspect_ratio
    raw_footage_metadata_hash["aspect_ratio"].presence || "16 / 9"
  end

  def raw_footage_watch_url
    raw_footage_metadata_hash["watch_url"].presence || raw_footage_url
  end

  def raw_footage_previewable?
    raw_footage_provider.present? && (raw_footage_embed_url.present? || raw_footage_social_preview?)
  end

  private

  def sync_raw_footage_metadata
    self.raw_footage_metadata = RawFootageUrlParser.metadata(raw_footage_url)
  end
end
