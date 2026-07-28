class NotificationJob < ApplicationJob
  def perform(project_id)
    Projects::Notifications::Service.call(project: Project.find(project_id), event_type: :project_created)
  end
end
