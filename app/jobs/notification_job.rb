class NotificationJob < ApplicationJob
  def perform(project_id)
    Projects::NotificationService.new(project_id).call
  end
end
