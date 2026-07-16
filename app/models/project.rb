class Project < ApplicationRecord
  belongs_to :client
  belongs_to :pm

  has_many :video_type_selections, dependent: :destroy
  has_many :video_types, through: :video_type_selections
  has_many :notifications, dependent: :destroy

  enum :status, { draft: "draft", in_progress: "in_progress", completed: "completed" }, default: :draft

  validates :name, presence: true, if: :in_progress?
  validates :raw_footage_url, presence: true, if: :in_progress?
end
