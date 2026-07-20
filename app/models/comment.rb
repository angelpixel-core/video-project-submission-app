class Comment < ApplicationRecord
  belongs_to :project
  belongs_to :author, polymorphic: true

  validates :body, presence: true
  validates :author, presence: true

  scope :chronological, -> { order(created_at: :asc) }
end
