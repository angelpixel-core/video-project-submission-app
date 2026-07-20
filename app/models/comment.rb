class Comment < ApplicationRecord
  after_create_commit :broadcast_refresh

  belongs_to :project
  belongs_to :author, polymorphic: true

  validates :body, presence: true
  validates :author, presence: true

  scope :chronological, -> { order(created_at: :asc) }

  def self.broadcast_refresh_for(project)
    return unless project.present?

    comment = project.comments.includes(:author).order(created_at: :desc).first
    return unless comment.present?

    ActionCable.server.broadcast(
      "project_comments_#{project.id}",
      {
        type: "comments_updated",
        comment_html: ApplicationController.render(partial: "projects/comment", locals: { comment: comment }),
        comment_count: project.comments.count
      }
    )
  end

  private

  def broadcast_refresh
    self.class.broadcast_refresh_for(project)
  end
end
