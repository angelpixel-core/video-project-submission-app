require "rails_helper"

RSpec.describe Payments::ProcessWebhookEventJob do
  it "delegates to the payment event handler when the event exists" do
    payment = Payment.create!(
      project: Project.create!(
        client: Client.create!(name: "Client", email: "client@example.com"),
        pm: PM.create!(name: "PM", email: "pm@example.com"),
        name: "Project",
        raw_footage_url: "https://example.com/raw.mov",
        status: :pending
      ),
      status: :processing,
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 50_000,
      currency: "USD",
      provider_reference: "fake-abc123"
    )

    event = PaymentWebhookEvent.create!(
      provider: "fake",
      provider_event_id: "evt_123",
      event_type: "payment.succeeded",
      payload: {
        "id" => "evt_123",
        "type" => "payment.succeeded",
        "data" => {
          "payment_id" => payment.id,
          "provider_reference" => payment.provider_reference,
          "amount_cents" => payment.amount_cents
        }
      },
      signature: "signature",
      status: :received,
      received_at: Time.current
    )

    service = instance_double(Payments::PaymentEventHandler)
    expect(Payments::PaymentEventHandler).to receive(:call).with(event: event).and_return(service)

    described_class.perform_now(event.id)
  end

  it "does nothing when the event is missing" do
    expect(Payments::PaymentEventHandler).not_to receive(:call)

    described_class.perform_now(-1)
  end
end
