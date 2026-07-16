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
    NotificationDelivery::LoggerChannel.new(project).call
  end
end
