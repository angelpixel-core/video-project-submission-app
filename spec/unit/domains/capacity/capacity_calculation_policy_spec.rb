require "rails_helper"

RSpec.describe Capacity::Domain::Policies::CapacityCalculationPolicy do
  it "reserves capacity based on active projects" do
    offer = VideoType.create!(name: "Highlight Reel #{SecureRandom.hex(4)}", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    client = workspace_account(:client, email: "client-capacity-#{SecureRandom.hex(4)}@example.com", name: "Client")
    pm = workspace_account(:pm, email: "pm-capacity-#{SecureRandom.hex(4)}@example.com", name: "PM")
    order = Ordering::Adapters::Persistence::Order::OrderRecord.create!(
      owner_account_id: client.id,
      participant_account_id: pm.id,
      name: "Order",
      status: :placed,
      payment_status: :pending,
      production_status: :not_started,
      delivery_status: :not_ready,
      uid: "order-#{SecureRandom.hex(4)}",
      created_at: Time.current,
      updated_at: Time.current
    )
    order.order_line_records.create!(
      offering_snapshot: {
        offering_id: offer.id,
        name: offer.name,
        description: offer.description,
        price_cents: offer.price_cents,
        output_format: offer.output_format
      },
      quantity: 2,
      line_total_cents: 50_000,
      created_at: Time.current,
      updated_at: Time.current
    )

    allow(ENV).to receive(:fetch).with("CAPACITY_TOTAL_UNITS", 100).and_return("3")

    expect(described_class.available_units_for(offer)).to eq(1)
  end
end
