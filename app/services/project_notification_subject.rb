class ProjectNotificationSubject
  def self.call(project:, recipient_role:, event_type:)
    new(project:, recipient_role:, event_type:).call
  end

  def initialize(project:, recipient_role:, event_type:)
    @project = project
    @recipient_role = recipient_role.to_s
    @event_type = event_type.to_s
  end

  def call
    case recipient_role
    when "pm"
      pm_subject
    else
      client_subject
    end
  end

  private

  attr_reader :project, :recipient_role, :event_type

  def pm_subject
    case event_type
    when "project_created"
      "New project created: #{project.name}"
    when "project_accepted"
      "Project accepted: #{project.name}"
    when "project_rejected"
      "Project rejected: #{project.name}"
    when "project_completed"
      "Project completed: #{project.name}"
    else
      "Project update: #{project.name}"
    end
  end

  def client_subject
    case event_type
    when "project_created"
      "Your project #{project.name} was created"
    when "project_accepted"
      "Your project #{project.name} was accepted"
    when "project_rejected"
      "Your project #{project.name} needs attention"
    when "project_completed"
      "Your project #{project.name} has been completed"
    else
      "Project update for #{project.name}"
    end
  end
end
