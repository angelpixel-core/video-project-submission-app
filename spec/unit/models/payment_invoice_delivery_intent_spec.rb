require "rails_helper"

RSpec.describe PaymentInvoiceDeliveryIntent do
  it "enqueues the dispatch job after commit when created" do
    client = Client.create!(name: "Client", email: "client@example.com")
    pm = PM.create!(name: "PM", email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, status: :draft)
    payment = Payment.create!(
      project: project,
      status: :succeeded,
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 20_000,
      currency: "USD",
      provider_reference: "inv-123"
    )

    intent = described_class.create!(payment: payment, status: :pending, scheduled_at: Time.current)

    expect(PaymentInvoiceDispatchJob).to receive(:perform_later).with(intent.id)

    intent.send(:enqueue_dispatch_job)
  end
end
