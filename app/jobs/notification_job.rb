class NotificationJob < ApplicationJob
  def perform(project_id)
    NotificationService.new(project_id).call
  end
end
