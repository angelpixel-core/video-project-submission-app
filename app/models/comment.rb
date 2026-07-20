class Comment < ApplicationRecord
  after_create_commit :broadcast_refresh

  belongs_to :project
  belongs_to :author, polymorphic: true

  validates :body, presence: true
  validates :author, presence: true

  scope :chronological, -> { order(created_at: :asc) }

  def self.broadcast_refresh_for(project)
    return unless project.present?

    ActionCable.server.broadcast("project_comments_#{project.id}", { type: "comments_updated" })
  end

  private

  def broadcast_refresh
    self.class.broadcast_refresh_for(project)
  end
end
