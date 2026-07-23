require "rails_helper"

RSpec.describe Payments::Notifications::Dispatcher do
  it "fans out to logger and email channels" do
    client = Client.create!(name: "Client", email: "client@example.com")
    pm = PM.create!(name: "PM", email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
    payment = Payment.create!(project: project, status: :succeeded, provider: "fake", idempotency_key: SecureRandom.uuid, amount_cents: 50_000, currency: "USD", provider_reference: "fake-abc123")
    intent = PaymentNotificationIntent.create!(payment: payment, project: project, event_type: "payment.succeeded", from_status: "processing", to_status: "succeeded", payload: { "payment_id" => payment.id }, status: :pending, scheduled_at: Time.current)

    logger_channel = instance_double(Payments::Notifications::LoggerChannel, call: true)
    email_channel = instance_double(Payments::Notifications::EmailChannel, call: true)

    expect(Payments::Notifications::LoggerChannel).to receive(:new).with(intent).and_return(logger_channel)
    expect(Payments::Notifications::EmailChannel).to receive(:new).with(intent).and_return(email_channel)
    expect(logger_channel).to receive(:call)
    expect(email_channel).to receive(:call)

    described_class.call(intent: intent)
  end
end
