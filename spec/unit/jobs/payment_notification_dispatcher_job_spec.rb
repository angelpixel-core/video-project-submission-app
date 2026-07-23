require "rails_helper"

RSpec.describe PaymentNotificationDispatcherJob do
  it "dispatches a pending intent and marks it sent" do
    payment = Payment.create!(
      project: Project.create!(client: Client.create!(name: "Client", email: "client@example.com"), pm: PM.create!(name: "PM", email: "pm@example.com"), name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending),
      status: :succeeded,
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 50_000,
      currency: "USD",
      provider_reference: "fake-abc123"
    )

    intent = PaymentNotificationIntent.create!(
      payment: payment,
      project: payment.project,
      event_type: "payment.succeeded",
      from_status: "processing",
      to_status: "succeeded",
      payload: { "payment_id" => payment.id },
      status: :pending,
      scheduled_at: Time.current
    )

    expect(Payments::Notifications::Dispatcher).to receive(:call).with(intent: intent)

    described_class.perform_now(intent.id)

    expect(intent.reload.sent?).to eq(true)
    expect(intent.processed_at).to be_present
    expect(intent.last_error).to be_nil
  end

  it "marks the intent failed when dispatch raises" do
    payment = Payment.create!(
      project: Project.create!(client: Client.create!(name: "Client", email: "client@example.com"), pm: PM.create!(name: "PM", email: "pm@example.com"), name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending),
      status: :succeeded,
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 50_000,
      currency: "USD",
      provider_reference: "fake-abc123"
    )

    intent = PaymentNotificationIntent.create!(
      payment: payment,
      project: payment.project,
      event_type: "payment.succeeded",
      from_status: "processing",
      to_status: "succeeded",
      payload: { "payment_id" => payment.id },
      status: :pending,
      scheduled_at: Time.current
    )

    allow(Payments::Notifications::Dispatcher).to receive(:call).and_raise(StandardError, "boom")

    expect do
      described_class.perform_now(intent.id)
    end.to raise_error(StandardError, "boom")

    expect(intent.reload.failed?).to eq(true)
    expect(intent.attempts_count).to eq(1)
    expect(intent.last_error).to eq("boom")
  end

  it "does nothing for missing or already sent intents" do
    expect(Payments::Notifications::Dispatcher).not_to receive(:call)

    described_class.perform_now(-1)

    payment = Payment.create!(
      project: Project.create!(client: Client.create!(name: "Client", email: "client@example.com"), pm: PM.create!(name: "PM", email: "pm@example.com"), name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending),
      status: :succeeded,
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 50_000,
      currency: "USD",
      provider_reference: "fake-abc123"
    )

    intent = PaymentNotificationIntent.create!(
      payment: payment,
      project: payment.project,
      event_type: "payment.succeeded",
      from_status: "processing",
      to_status: "succeeded",
      payload: { "payment_id" => payment.id },
      status: :sent,
      scheduled_at: Time.current,
      processed_at: Time.current
    )

    expect(Payments::Notifications::Dispatcher).not_to receive(:call)

    described_class.perform_now(intent.id)
  end
end
