class Project < ApplicationRecord
  include AASM

  belongs_to :client
  belongs_to :pm, class_name: "PM"

  has_many :video_type_selections, dependent: :destroy
  has_many :video_types, through: :video_type_selections
  has_many :notifications, dependent: :destroy

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
    video_type_selections.includes(:video_type).sum do |selection|
      selection.quantity * selection.video_type.price_cents
    end
  end

  def submitted?
    pending? || in_progress? || completed?
  end
end
