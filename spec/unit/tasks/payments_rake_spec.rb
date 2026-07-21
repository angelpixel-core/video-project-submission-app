require "rails_helper"
require "rake"

RSpec.describe "payments rake tasks" do
  before(:all) do
    Rake::Task.define_task(:environment)
    load Rails.root.join("lib/tasks/payments.rake")
  end

  around do |example|
    original_env = {
      "WEBHOOK_URL" => ENV["WEBHOOK_URL"],
      "PROVIDER" => ENV["PROVIDER"],
      "EVENT_ID" => ENV["EVENT_ID"],
      "TYPE" => ENV["TYPE"],
      "PAYMENT_ID" => ENV["PAYMENT_ID"],
      "PROVIDER_REFERENCE" => ENV["PROVIDER_REFERENCE"],
      "AMOUNT_CENTS" => ENV["AMOUNT_CENTS"]
    }

    example.run
  ensure
    original_env.each do |key, value|
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end

    Rake::Task["payments:simulate_webhook"].reenable
    Rake::Task["payments:send_signed_fake_webhook"].reenable
  end

  it "defaults to localhost and forwards env vars to the simulator" do
    expect(Payments::WebhookSimulator).to receive(:call).with(
      webhook_url: "http://localhost:3000/payments/webhooks/fake/events",
      provider: "fake",
      event_id: "evt_123",
      type: "payment.succeeded",
      payment_id: "1",
      provider_reference: "fake-abc123",
      amount_cents: "50000"
    ).and_return(Payments::Result::Success.(data: { status_code: 202, body: "accepted" }))

    Rake::Task["payments:simulate_webhook"].invoke
  end

  it "sends a signed fake webhook with a succeeded default type" do
    expect(Payments::WebhookSimulator).to receive(:call).with(
      webhook_url: "http://localhost:3000/payments/webhooks/fake/events",
      provider: "fake",
      event_id: "evt_123",
      type: "payment.succeeded",
      payment_id: "1",
      provider_reference: "fake-abc123",
      amount_cents: "50000"
    ).and_return(Payments::Result::Success.(data: { status_code: 202, body: "accepted" }))

    Rake::Task["payments:send_signed_fake_webhook"].invoke
  end

  it "treats blank env vars like unset values" do
    ENV["WEBHOOK_URL"] = ""
    ENV["PROVIDER"] = ""
    ENV["EVENT_ID"] = ""
    ENV["TYPE"] = ""
    ENV["PAYMENT_ID"] = ""
    ENV["PROVIDER_REFERENCE"] = ""
    ENV["AMOUNT_CENTS"] = ""

    expect(Payments::WebhookSimulator).to receive(:call).with(
      webhook_url: "http://localhost:3000/payments/webhooks/fake/events",
      provider: "fake",
      event_id: "evt_123",
      type: "payment.succeeded",
      payment_id: "1",
      provider_reference: "fake-abc123",
      amount_cents: "50000"
    ).and_return(Payments::Result::Success.(data: { status_code: 202, body: "accepted" }))

    Rake::Task["payments:simulate_webhook"].invoke
  end

  it "uses an explicit webhook url when provided" do
    ENV["WEBHOOK_URL"] = "http://example.com/webhooks"

    expect(Payments::WebhookSimulator).to receive(:call).with(
      webhook_url: "http://example.com/webhooks",
      provider: "fake",
      event_id: "evt_123",
      type: "payment.succeeded",
      payment_id: "1",
      provider_reference: "fake-abc123",
      amount_cents: "50000"
    ).and_return(Payments::Result::Success.(data: { status_code: 202, body: "accepted" }))

    Rake::Task["payments:simulate_webhook"].invoke
  end
end
