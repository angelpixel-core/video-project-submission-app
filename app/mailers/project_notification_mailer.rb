class ProjectNotificationMailer < ApplicationMailer
  def project_created(project, recipient_role:)
    notify(project, recipient_role, :project_created)
  end

  def project_accepted(project, recipient_role:)
    notify(project, recipient_role, :project_accepted)
  end

  def project_rejected(project, recipient_role:)
    notify(project, recipient_role, :project_rejected)
  end

  private

  def notify(project, recipient_role, event_type)
    @project = project
    @event_type = event_type.to_s
    @recipient_role = recipient_role.to_s

    mail(
      to: recipient_email(project, recipient_role),
      subject: subject_for(project, recipient_role, event_type),
      template_path: template_path_for(recipient_role),
      template_name: "notification"
    )
  end

  def recipient_email(project, recipient_role)
    recipient_role.to_s == "pm" ? project.participant.email : project.owner.email
  end

  def template_path_for(recipient_role)
    recipient_role.to_s == "pm" ? "pm_notification_mailer" : "client_notification_mailer"
  end

  def subject_for(project, recipient_role, event_type)
    case recipient_role.to_s
    when "pm"
      case event_type.to_s
      when "project_created"
        "New project created: #{project.name}"
      when "project_accepted"
        "Project accepted: #{project.name}"
      when "project_rejected"
        "Project rejected: #{project.name}"
      else
        "Project update: #{project.name}"
      end
    else
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
end
