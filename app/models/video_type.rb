class VideoType < ApplicationRecord
  has_many :video_type_selections, dependent: :destroy
  has_many :projects, through: :video_type_selections

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :output_format, presence: true
end
