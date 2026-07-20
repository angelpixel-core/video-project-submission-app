class ProjectCommentsChannel < ApplicationCable::Channel
  def subscribed
    project_id = params[:project_id].presence
    reject unless project_id.present?

    stream_from "project_comments_#{project_id}"
  end
end
