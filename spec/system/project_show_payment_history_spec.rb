require "rails_helper"

def switch_workspace_to(mode)
  find(".account-menu-trigger").click
  click_button "Switch to #{mode}"
end

RSpec.describe "Project show payment history", type: :system, js: true do
  around do |example|
    original_client = ENV["DEFAULT_CLIENT_EMAIL"]
    original_pm = ENV["DEFAULT_PM_EMAIL"]

    ENV["DEFAULT_CLIENT_EMAIL"] = "client@example.com"
    ENV["DEFAULT_PM_EMAIL"] = "pm@example.com"

    example.run
  ensure
    ENV["DEFAULT_CLIENT_EMAIL"] = original_client
    ENV["DEFAULT_PM_EMAIL"] = original_pm
  end

  before do
    driven_by :selenium_chrome_headless

    Client.create!(name: "Default Client", email: "client@example.com")
    PM.create!(name: "Default PM", email: "pm@example.com")
    VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
  end

  it "shows payment history to the pm and keeps it hidden from the client workspace" do
    client = Client.find_by!(email: "client@example.com")
    pm = PM.find_by!(email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project Alpha", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    payment = Payment.create!(
      project: project,
      status: :processing,
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 50_000,
      currency: "USD",
      provider_reference: "fake-abc123"
    )

    PaymentAttempt.create!(
      payment: payment,
      status: :submitted,
      provider: payment.provider,
      idempotency_key: payment.idempotency_key,
      provider_reference: payment.provider_reference,
      request_payload: { "payment_id" => payment.id },
      response_payload: { "status" => "accepted" }
    )

    PaymentWebhookEvent.create!(
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
      status: :processed,
      received_at: 1.minute.ago,
      processed_at: Time.current
    )

    visit project_path(project)

    expect(page).to have_no_css("#payment-history", visible: :visible)

    switch_workspace_to("PM")

    expect(page).to have_css("#payment-history", visible: :visible)
    expect(page).to have_css("#payment-history", text: "Webhook events and attempts")
    expect(page).to have_css("#payment-history", text: "payment.succeeded")
    expect(page).to have_css("#payment-history", text: "submitted")
    expect(page).to have_css("#payment-history", text: "PROCESSED")
  end

  it "shows confirmed when the payment has been successfully processed" do
    client = Client.find_by!(email: "client@example.com")
    pm = PM.find_by!(email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project Beta", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    payment = Payment.create!(
      project: project,
      status: :processing,
      provider: "fake",
      idempotency_key: SecureRandom.uuid,
      amount_cents: 50_000,
      currency: "USD",
      provider_reference: "fake-xyz789"
    )

    PaymentAttempt.create!(
      payment: payment,
      status: :submitted,
      provider: payment.provider,
      idempotency_key: payment.idempotency_key,
      provider_reference: payment.provider_reference,
      request_payload: { "payment_id" => payment.id },
      response_payload: { "status" => "accepted" }
    )

    event = PaymentWebhookEvent.create!(
      provider: "fake",
      provider_event_id: "evt_456",
      event_type: "payment.succeeded",
      payload: {
        "id" => "evt_456",
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

    Payments::ProcessWebhookEventJob.perform_now(event.id)

    visit project_path(project)

    switch_workspace_to("PM")

    expect(page).to have_css("#payment-history", text: "succeeded")
    expect(page).to have_css("#payment-history", text: "Confirmed")
    expect(page).to have_css("#payment-history", text: payment.reload.confirmed_at.to_fs(:short))
  end
end
