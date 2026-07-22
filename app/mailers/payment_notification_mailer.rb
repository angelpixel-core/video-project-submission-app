class PaymentNotificationMailer < ApplicationMailer
  def payment_status_changed(intent)
    @intent = intent
    @payment = intent.payment
    @project = intent.project

    mail(to: @project.client.email, subject: subject_for(intent))
  end

  private

  def subject_for(intent)
    "Payment #{intent.to_status.humanize.downcase} for #{@project.name}"
  end
end
