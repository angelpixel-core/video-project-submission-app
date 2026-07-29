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

  def project_completed(project, recipient_role:)
    notify(project, recipient_role, :project_completed)
  end

  private

  def notify(project, recipient_role, event_type)
    @project = project
    @event_type = event_type.to_s
    @recipient_role = recipient_role.to_s

    mail(
      to: recipient_email(project, recipient_role),
      subject: ProjectNotificationSubject.call(project:, recipient_role:, event_type:),
      template_name: "notification"
    )
  end

  def recipient_email(project, recipient_role)
    recipient_role.to_s == "pm" ? project.participant.email : project.owner.email
  end
end
