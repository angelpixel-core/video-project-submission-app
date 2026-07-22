require "rails_helper"

RSpec.describe Payments::GenerateInvoiceJob do
  it "attaches an invoice and creates a delivery intent once" do
    client = Client.create!(name: "Client", email: "client@example.com")
    pm = PM.create!(name: "PM", email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :draft)
    payment = Payment.create!(
      project: project,
      status: :succeeded,
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 20_000,
      currency: "USD",
      provider_reference: "inv-123"
    )

    expect do
      described_class.perform_now(payment.id)
    end.to change(PaymentInvoiceDeliveryIntent, :count).by(1)

    payment.reload
    expect(payment.invoice_generated_at).to be_present
    expect(payment.invoice_number).to eq("INV-00000#{payment.id}")
    expect(payment.invoice_document).to be_attached
    expect(payment.invoice_document.filename.to_s).to eq("INV-00000#{payment.id}.html")
  end
end
