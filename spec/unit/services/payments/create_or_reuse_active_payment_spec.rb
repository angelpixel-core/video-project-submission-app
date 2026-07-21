require "rails_helper"

RSpec.describe Payments::CreateOrReuseActivePayment do
  it "creates an active payment and its first attempt" do
    client = Client.create!(name: "Client", email: "client@example.com")
    pm = PM.create!(name: "PM", email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    project.video_type_selections.create!(video_type: video_type, quantity: 1)

    payment = described_class.new(project: project).call

    expect(payment).to be_active
    expect(payment.amount_cents).to eq(25_000)
    expect(payment.payment_attempts.count).to eq(1)
    expect(payment.payment_attempts.first.idempotency_key).to eq(payment.idempotency_key)
  end

  it "reuses the existing active payment instead of creating a duplicate" do
    client = Client.create!(name: "Client", email: "client@example.com")
    pm = PM.create!(name: "PM", email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    project.video_type_selections.create!(video_type: video_type, quantity: 1)

    first_payment = described_class.new(project: project).call

    expect do
      second_payment = described_class.new(project: project).call
      expect(second_payment).to eq(first_payment)
    end.not_to change(Payment, :count)

    expect(PaymentAttempt.count).to eq(1)
  end
end
