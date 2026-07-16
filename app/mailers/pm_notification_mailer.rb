class PmNotificationMailer < ApplicationMailer
  def project_created(project)
    @project = project
    mail(to: project.pm.email, subject: "New project created: #{project.name}")
  end
end
