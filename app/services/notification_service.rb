class NotificationService
  def initialize(project_id)
    @project_id = project_id
  end

  def call
    project = Project.includes(:pm).find(project_id)
    Rails.logger.info("Notification for PM #{project.pm.email}: project #{project.id} was created")
  end

  private

  attr_reader :project_id
end
