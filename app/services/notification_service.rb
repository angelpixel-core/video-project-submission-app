class NotificationService
  def initialize(project_id)
    @project_id = project_id
  end

  def call
    project = load_project

    deliver_notification(project)
  end

  private

  attr_reader :project_id

  def load_project
    Project.includes(:pm).find(project_id)
  end

  def deliver_notification(project)
    Rails.logger.info("Notification for PM #{project.pm.email}: project #{project.id} was created")
  end
end
