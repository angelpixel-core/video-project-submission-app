class ClientNotificationMailer < ApplicationMailer
  def project_created(project)
    notify(project, :project_created)
  end

  def project_accepted(project)
    notify(project, :project_accepted)
  end

  def project_rejected(project)
    notify(project, :project_rejected)
  end

  private

  def notify(project, event_type)
    @project = project
    @event_type = event_type.to_s

    mail(to: project.client.email, subject: subject_for(project, event_type), template_name: "notification")
  end

  def subject_for(project, event_type)
    case event_type.to_s
    when "project_created"
      "Your project #{project.name} was created"
    when "project_accepted"
      "Your project #{project.name} was accepted"
    when "project_rejected"
      "Your project #{project.name} needs attention"
    else
      "Project update for #{project.name}"
    end
  end
end
