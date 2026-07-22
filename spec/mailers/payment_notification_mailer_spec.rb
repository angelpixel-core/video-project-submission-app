require "rails_helper"

RSpec.describe PaymentNotificationMailer do
  describe "payment_status_changed" do
    it "sends a compact text email for a succeeded payment" do
      client = Client.create!(name: "Client", email: "client@example.com")
      pm = PM.create!(name: "PM", email: "pm@example.com")
      project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
      payment = Payment.create!(project: project, status: :succeeded, provider: "fake", idempotency_key: SecureRandom.uuid, amount_cents: 50_000, currency: "USD", provider_reference: "fake-abc123")
      intent = PaymentNotificationIntent.create!(payment: payment, project: project, event_type: "payment.succeeded", from_status: "processing", to_status: "succeeded", payload: { "payment_id" => payment.id }, status: :pending, scheduled_at: Time.current)

      mail = described_class.payment_status_changed(intent)

      expect(mail.to).to eq([ "client@example.com" ])
      expect(mail.subject).to eq("Payment succeeded for Project")
      expect(mail.body.encoded).to include("Payment succeeded")
      expect(mail.body.encoded).to include("Project: Project")
      expect(mail.body.encoded).to include("Client: Client")
      expect(mail.body.encoded).to include("Status: Processing -> Succeeded")
      expect(mail.body.encoded).to include("Amount: USD 500.00")
    end

    it "sends a compact text email for a failed payment" do
      client = Client.create!(name: "Client", email: "client@example.com")
      pm = PM.create!(name: "PM", email: "pm@example.com")
      project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
      payment = Payment.create!(project: project, status: :failed, provider: "fake", idempotency_key: SecureRandom.uuid, amount_cents: 25_000, currency: "USD", provider_reference: "fake-def456")
      intent = PaymentNotificationIntent.create!(payment: payment, project: project, event_type: "payment.failed", from_status: "processing", to_status: "failed", payload: { "payment_id" => payment.id }, status: :pending, scheduled_at: Time.current)

      mail = described_class.payment_status_changed(intent)

      expect(mail.to).to eq([ "client@example.com" ])
      expect(mail.subject).to eq("Payment failed for Project")
      expect(mail.body.encoded).to include("Payment failed")
      expect(mail.body.encoded).to include("Status: Processing -> Failed")
      expect(mail.body.encoded).to include("Amount: USD 250.00")
    end
  end
end
