class VideoTypeSelection < ApplicationRecord
  belongs_to :project
  belongs_to :video_type

  validates :quantity, numericality: { greater_than: 0, only_integer: true }
  validates :video_type_id, uniqueness: { scope: :project_id }
end
