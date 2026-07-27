require "rails_helper"

RSpec.describe Payments::Application::Commands::CreatePayment do
  it "creates an active payment and its first attempt" do
    client = workspace_account(:client, email: "client@example.com", name: "Client")
    pm = workspace_account(:pm, email: "pm@example.com", name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    project.video_type_selections.create!(video_type: video_type, quantity: 1)

    result = described_class.(project: project)
    payment = result.data.fetch(:payment)

    expect(result).to be_success
    expect(payment).to be_active
    expect(payment.amount_cents).to eq(25_000)
    expect(payment.provider_reference).to eq("fake-#{payment.idempotency_key}")
    expect(payment.payment_attempts.count).to eq(1)
    expect(payment.payment_attempts.first.idempotency_key).to eq(payment.idempotency_key)
    expect(payment.payment_attempts.first.status).to eq("submitted")
  end

  it "reuses the existing active payment instead of creating a duplicate" do
    client = workspace_account(:client, email: "client@example.com", name: "Client")
    pm = workspace_account(:pm, email: "pm@example.com", name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    project.video_type_selections.create!(video_type: video_type, quantity: 1)

    first_result = described_class.(project: project)
    first_payment = first_result.data.fetch(:payment)

    expect do
      second_result = described_class.(project: project)
      second_payment = second_result.data.fetch(:payment)
      expect(second_payment).to eq(first_payment)
    end.not_to change(Payments::Domain::Aggregates::Payment, :count)

    expect(first_result).to be_success
    expect(Payments::Domain::Entities::PaymentAttempt.count).to eq(1)
  end

  it "returns a failure when the provider rejects the payment" do
    client = workspace_account(:client, email: "client@example.com", name: "Client")
    pm = workspace_account(:pm, email: "pm@example.com", name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)

    allow(Payments::Adapters::Outbound::Gateways::Fake).to receive(:call).and_return(
      Core::Result::Failure.(message: "Rejected", code: :provider_rejected, data: { payment_id: 123 })
    )

    result = described_class.(project: project)

    expect(result).to be_failure
    expect(result.code).to eq(:provider_rejected)
    expect(result.message).to eq("Rejected")
  end
end
