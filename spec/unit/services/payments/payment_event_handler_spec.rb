require "rails_helper"

RSpec.describe Payments::PaymentEventHandler do
  def build_payment(status: :processing)
    client = Client.create!(name: "Client", email: "client@example.com")
    pm = PM.create!(name: "PM", email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)

    payment = Payment.create!(
      project: project,
      status: status,
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
      request_payload: {
        payment_id: payment.id,
        project_id: payment.project_id,
        amount_cents: payment.amount_cents,
        currency: payment.currency,
        idempotency_key: payment.idempotency_key
      },
      response_payload: {
        provider_reference: payment.provider_reference,
        status: "accepted"
      }
    )

    payment
  end

  def build_event(payment:, event_type: "payment.succeeded", event_id: "evt_123", demo_fail_once: false)
    PaymentWebhookEvent.create!(
      provider: "fake",
      provider_event_id: event_id,
      event_type: event_type,
      payment: payment,
      project: payment.project,
      payload: {
        "id" => event_id,
        "type" => event_type,
        "data" => {
          "payment_id" => payment.id,
          "provider_reference" => payment.provider_reference,
          "amount_cents" => payment.amount_cents,
          "demo_fail_once" => demo_fail_once
        }
      },
      signature: "signature",
      status: :received,
      received_at: Time.current
    )
  end

  it "processes a succeeded event once" do
    payment = build_payment
    event = build_event(payment: payment)

    result = described_class.(event: event)

    expect(result).to be_success
    expect(result.data[:applied]).to eq(true)

    payment.reload
    event.reload

    expect(payment.status).to eq("succeeded")
    expect(payment.confirmed_at).to be_present
    expect(payment.payment_attempts.first.status).to eq("succeeded")
    expect(event.status).to eq("processed")
    expect(event.processed_at).to be_present
    expect(event.error_message).to be_nil
    expect(event.processing_attempts_count).to eq(1)
    expect(event.last_attempted_at).to be_present
  end

  it "is idempotent when the same processed event is handled again" do
    payment = build_payment
    event = build_event(payment: payment)

    described_class.(event: event)

    expect do
      described_class.(event: event.reload)
    end.not_to change { payment.reload.status }

    expect(event.reload.status).to eq("processed")
    expect(event.processed_at).to be_present
  end

  it "marks unknown event types as failed" do
    payment = build_payment
    event = build_event(payment: payment, event_type: "payment.reopened")

    result = described_class.(event: event)

    expect(result).to be_failure
    expect(result.code).to eq(:unknown_event_type)
    expect(event.reload.status).to eq("failed")
    expect(event.error_message).to eq("Unsupported payment webhook event type.")
    expect(event.processing_attempts_count).to eq(1)
    expect(event.last_failure_message).to eq("Unsupported payment webhook event type.")
    expect(payment.reload.status).to eq("processing")
  end

  it "fails once for the demo retry flag and succeeds on the next attempt" do
    payment = build_payment
    event = build_event(payment: payment, demo_fail_once: true)

    expect { described_class.(event: event) }.to raise_error(Payments::DemoTransientFailure, Payments::PaymentEventHandler::DEMO_FAILURE_MESSAGE)
    expect(event.reload.status).to eq("failed")
    expect(event.processing_attempts_count).to eq(1)
    expect(event.last_failure_message).to eq(Payments::PaymentEventHandler::DEMO_FAILURE_MESSAGE)

    second_result = described_class.(event: event.reload)

    expect(second_result).to be_success
    expect(second_result.data[:applied]).to eq(true)
    expect(event.reload.status).to eq("processed")
    expect(event.processing_attempts_count).to eq(2)
    expect(payment.reload.status).to eq("succeeded")
  end

  it "ignores an out-of-order failure after success" do
    payment = build_payment
    success_event = build_event(payment: payment, event_type: "payment.succeeded", event_id: "evt_success")
    failure_event = build_event(payment: payment, event_type: "payment.failed", event_id: "evt_failure")

    described_class.(event: success_event)
    result = described_class.(event: failure_event)

    expect(result).to be_success
    expect(result.data[:applied]).to eq(false)
    expect(result.data[:reason]).to eq(:stale_payment_state)
    expect(payment.reload.status).to eq("succeeded")
    expect(failure_event.reload.status).to eq("processed")
    expect(failure_event.processed_at).to be_present
    expect(failure_event.processing_attempts_count).to eq(1)
  end
end
