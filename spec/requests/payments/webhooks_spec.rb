require "rails_helper"

RSpec.describe "Payments webhooks requests" do
  def webhook_body(event_id: "evt_123", type: "payment.succeeded")
    {
      id: event_id,
      type: type,
      data: {
        payment_id: 1,
        provider_reference: "fake-abc123",
        amount_cents: 50_000
      }
    }.to_json
  end

  def webhook_signature(body)
    OpenSSL::HMAC.hexdigest("SHA256", Payments::WebhookIngest::WEBHOOK_SECRET, body)
  end

  it "accepts a valid provider event" do
    body = webhook_body

    expect do
      post payments_webhook_events_path(provider: "fake"), params: body, headers: {
        "CONTENT_TYPE" => "application/json",
        "X-Payment-Signature" => webhook_signature(body)
      }
    end.to change(PaymentWebhookEvent, :count).by(1)

    expect(response).to have_http_status(:accepted)

    event = PaymentWebhookEvent.order(:created_at).last
    expect(event.provider).to eq("fake")
    expect(event.provider_event_id).to eq("evt_123")
    expect(event.event_type).to eq("payment.succeeded")
    expect(event.payload).to include("data" => hash_including("provider_reference" => "fake-abc123"))
    expect(event.status).to eq("received")
  end

  it "returns ok for a duplicate provider event" do
    body = webhook_body
    headers = {
      "CONTENT_TYPE" => "application/json",
      "X-Payment-Signature" => webhook_signature(body)
    }

    post payments_webhook_events_path(provider: "fake"), params: body, headers: headers
    expect do
      post payments_webhook_events_path(provider: "fake"), params: body, headers: headers
    end.not_to change(PaymentWebhookEvent, :count)

    expect(response).to have_http_status(:ok)
  end

  it "rejects an invalid signature" do
    body = webhook_body

    post payments_webhook_events_path(provider: "fake"), params: body, headers: {
      "CONTENT_TYPE" => "application/json",
      "X-Payment-Signature" => "bad-signature"
    }

    expect(response).to have_http_status(:unauthorized)
    expect(PaymentWebhookEvent.count).to eq(0)
  end

  it "rejects malformed json" do
    body = "{not-json"

    post payments_webhook_events_path(provider: "fake"), params: body, headers: {
      "CONTENT_TYPE" => "application/json",
      "X-Payment-Signature" => webhook_signature(body)
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(PaymentWebhookEvent.count).to eq(0)
  end

  it "rejects unknown providers" do
    body = webhook_body

    post payments_webhook_events_path(provider: "unknown"), params: body, headers: {
      "CONTENT_TYPE" => "application/json",
      "X-Payment-Signature" => webhook_signature(body)
    }

    expect(response).to have_http_status(:not_found)
    expect(PaymentWebhookEvent.count).to eq(0)
  end
end
