class Comment < ApplicationRecord
  after_create_commit :broadcast_refresh

  belongs_to :project
  belongs_to :author_account, class_name: "Identity::Domain::Aggregates::Account", foreign_key: :author_account_id

  validates :body, presence: true
  validates :author_account, presence: true

  scope :chronological, -> { order(created_at: :asc) }

  def author
    case author_type
    when "Client" then Client.find_by(id: author_id)
    when "PM" then PM.find_by(id: author_id)
    else author_account
    end
  end

  def author=(value)
    self.author_account = value
    self.author_type = value.class.name
    self.author_id = value.id
  end

  def self.broadcast_refresh_for(project)
    return unless project.present?

    comment = project.comments.includes(:author_account).order(created_at: :desc).first
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
