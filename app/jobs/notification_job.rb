class NotificationJob < ApplicationJob
  def perform(project_id)
    Projects::Notifications::Service.new(project_id).call
  end
end
