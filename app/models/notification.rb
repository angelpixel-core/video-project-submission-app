class Notification < ApplicationRecord
  belongs_to :project
  belongs_to :pm

  validates :kind, presence: true
  validates :body, presence: true
end
