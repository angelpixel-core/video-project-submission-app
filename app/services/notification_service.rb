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
    delivery_channels(project).each(&:call)
  end

  def delivery_channels(project)
    [
      NotificationDelivery::LoggerChannel.new(project),
      NotificationDelivery::EmailChannel.new(project)
    ]
  end
end
