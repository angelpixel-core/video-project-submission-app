require "rails_helper"

RSpec.describe Payments::Domain::Entities::PaymentReconciliationResult do
  it "persists the latest snapshot and an auditable result" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, status: :draft)
    payment = Payments::Domain::Aggregates::Payment.create!(
      project: project,
      status: "pending",
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 1,
      currency: "USD"
    )

    result = payment.record_reconciliation_result!(
      status: "matched",
      result_code: "provider_confirmed",
      expected_status: "succeeded",
      actual_status: "succeeded",
      provider_reference: "provider-123",
      snapshot: { "status" => "succeeded", "amount_cents" => 1 },
      details: { "source" => "webhook" }
    )

    expect(result).to be_persisted
    expect(result.payment).to eq(payment)
    expect(result.snapshot).to include("status" => "succeeded")
    expect(payment.reload.payment_reconciliation_snapshot).to include("amount_cents" => 1)
    expect(payment.payment_reconciliation_results).to contain_exactly(result)
  end

  it "normalizes status and stores a reconciliation timestamp" do
    result = described_class.new(payment: unsaved_payment, status: " matched ", snapshot: { "status" => "succeeded" })

    expect(result).to be_valid
    expect(result.status).to eq("matched")
    expect(result.reconciled_at).to be_present
  end

  it "rejects unknown statuses" do
    result = described_class.new(payment: unsaved_payment, status: "unknown", snapshot: {})

    expect(result).not_to be_valid
    expect(result.errors[:status]).to include("is not included in the list")
  end

  private

  def unsaved_payment
    @unsaved_payment ||= Payments::Domain::Aggregates::Payment.new(
      project: Order.new,
      status: "pending",
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 1,
      currency: "USD"
    )
  end
end
