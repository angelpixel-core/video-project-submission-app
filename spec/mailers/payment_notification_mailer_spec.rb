require "rails_helper"

RSpec.describe Payments::Adapters::Outbound::Email::PaymentNotificationMailer do
  describe "payment_status_changed" do
    it "sends a compact text email for a succeeded payment to the client" do
      client = Client.create!(name: "Client", email: "client@example.com")
      pm = PM.create!(name: "PM", email: "pm@example.com")
      project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
      payment = Payments::Domain::Aggregates::Payment.create!(project: project, status: :succeeded, provider: "fake", idempotency_key: SecureRandom.uuid, amount_cents: 50_000, currency: "USD", provider_reference: "fake-abc123")
      intent = Payments::Domain::Entities::PaymentNotificationIntent.create!(payment: payment, project: project, event_type: "payment.succeeded", from_status: "processing", to_status: "succeeded", payload: { "payment_id" => payment.id }, status: :pending, scheduled_at: Time.current)

      mail = described_class.payment_status_changed(intent, recipient_role: :client)

      expect(mail.to).to eq([ "client@example.com" ])
      expect(mail.subject).to eq("Payment succeeded for Project")
      expect(mail.body.encoded).to include("Your payment was confirmed")
      expect(mail.body.encoded).to include("Project: Project")
      expect(mail.body.encoded).to include("Client: Client")
      expect(mail.body.encoded).to include("Payment status: Processing -> Succeeded")
      expect(mail.body.encoded).to include("Amount: USD 500.00")
    end

    it "sends a compact text email for a succeeded payment to the pm" do
      client = Client.create!(name: "Client", email: "client@example.com")
      pm = PM.create!(name: "PM", email: "pm@example.com")
      project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
      payment = Payments::Domain::Aggregates::Payment.create!(project: project, status: :succeeded, provider: "fake", idempotency_key: SecureRandom.uuid, amount_cents: 25_000, currency: "USD", provider_reference: "fake-def456")
      intent = Payments::Domain::Entities::PaymentNotificationIntent.create!(payment: payment, project: project, event_type: "payment.succeeded", from_status: "processing", to_status: "succeeded", payload: { "payment_id" => payment.id, "provider_event_id" => "evt_123", "webhook_event_id" => 5 }, status: :pending, scheduled_at: Time.current)

      mail = described_class.payment_status_changed(intent, recipient_role: :pm)

      expect(mail.to).to eq([ "pm@example.com" ])
      expect(mail.subject).to eq("Payment succeeded for Project - PM update")
      expect(mail.body.encoded).to include("Payment confirmation succeeded")
      expect(mail.body.encoded).to include("Webhook event id: 5")
      expect(mail.body.encoded).to include("Provider event id: evt_123")
      expect(mail.body.encoded).to include("Project status: Succeeded")
    end

    it "sends a compact text email for a failed payment to the client" do
      client = Client.create!(name: "Client", email: "client@example.com")
      pm = PM.create!(name: "PM", email: "pm@example.com")
      project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
      payment = Payments::Domain::Aggregates::Payment.create!(project: project, status: :failed, provider: "fake", idempotency_key: SecureRandom.uuid, amount_cents: 25_000, currency: "USD", provider_reference: "fake-def456")
      intent = Payments::Domain::Entities::PaymentNotificationIntent.create!(payment: payment, project: project, event_type: "payment.failed", from_status: "processing", to_status: "failed", payload: { "payment_id" => payment.id }, status: :pending, scheduled_at: Time.current)

      mail = described_class.payment_status_changed(intent, recipient_role: :client)

      expect(mail.to).to eq([ "client@example.com" ])
      expect(mail.subject).to eq("Payment failed for Project")
      expect(mail.body.encoded).to include("Your payment could not be confirmed")
      expect(mail.body.encoded).to include("Payment status: Processing -> Failed")
      expect(mail.body.encoded).to include("Amount: USD 250.00")
    end

    it "sends a compact text email for a failed payment to the pm" do
      client = Client.create!(name: "Client", email: "client@example.com")
      pm = PM.create!(name: "PM", email: "pm@example.com")
      project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
      payment = Payments::Domain::Aggregates::Payment.create!(project: project, status: :failed, provider: "fake", idempotency_key: SecureRandom.uuid, amount_cents: 25_000, currency: "USD", provider_reference: "fake-def456")
      intent = Payments::Domain::Entities::PaymentNotificationIntent.create!(payment: payment, project: project, event_type: "payment.failed", from_status: "processing", to_status: "failed", payload: { "payment_id" => payment.id, "provider_event_id" => "evt_456", "webhook_event_id" => 7 }, status: :pending, scheduled_at: Time.current)

      mail = described_class.payment_status_changed(intent, recipient_role: :pm)

      expect(mail.to).to eq([ "pm@example.com" ])
      expect(mail.subject).to eq("Payment failed for Project - PM update")
      expect(mail.body.encoded).to include("Payment confirmation failed")
      expect(mail.body.encoded).to include("Webhook event id: 7")
      expect(mail.body.encoded).to include("Provider event id: evt_456")
      expect(mail.body.encoded).to include("Project status: Failed")
    end
  end
end
