require "rails_helper"

RSpec.describe PaymentNotifications::EmailChannel do
  it "delivers the payment status email to client and pm" do
    client = Client.create!(name: "Client", email: "client@example.com")
    pm = PM.create!(name: "PM", email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
    payment = Payment.create!(project: project, status: :succeeded, provider: "fake", idempotency_key: SecureRandom.uuid, amount_cents: 50_000, currency: "USD", provider_reference: "fake-abc123")
    intent = PaymentNotificationIntent.create!(payment: payment, project: project, event_type: "payment.succeeded", from_status: "processing", to_status: "succeeded", payload: { "payment_id" => payment.id, "provider_event_id" => "evt_123", "webhook_event_id" => 5 }, status: :pending, scheduled_at: Time.current)

    client_mail = instance_double(ActionMailer::MessageDelivery)
    pm_mail = instance_double(ActionMailer::MessageDelivery)

    expect(PaymentNotificationMailer).to receive(:payment_status_changed).with(intent, recipient_role: :client).and_return(client_mail)
    expect(PaymentNotificationMailer).to receive(:payment_status_changed).with(intent, recipient_role: :pm).and_return(pm_mail)
    expect(client_mail).to receive(:deliver_now)
    expect(pm_mail).to receive(:deliver_now)

    described_class.new(intent).call
  end
end
