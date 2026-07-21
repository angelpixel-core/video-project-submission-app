require "rails_helper"

RSpec.describe PaymentAttempt do
  it "is an ActiveRecord model" do
    expect(described_class.superclass).to eq(ApplicationRecord)
  end

  it "belongs to a payment and requires unique idempotency keys" do
    client = Client.create!(name: "Client", email: "client@example.com")
    pm = PM.create!(name: "PM", email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, status: :draft)
    payment = Payment.create!(
      project: project,
      status: :pending,
      provider: "fake",
      idempotency_key: "payment-key",
      amount_cents: 10_000,
      currency: "usd"
    )

    attempt = described_class.create!(
      payment: payment,
      status: :pending,
      provider: "fake",
      idempotency_key: "attempt-key",
      request_payload: { "amount_cents" => 10_000 },
      response_payload: { "status" => "pending" }
    )

    expect(attempt.payment).to eq(payment)

    duplicate = described_class.new(
      payment: payment,
      status: :submitted,
      provider: "fake",
      idempotency_key: "attempt-key",
      request_payload: { "amount_cents" => 10_000 },
      response_payload: { "status" => "pending" }
    )

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:idempotency_key]).to be_present
  end
end
