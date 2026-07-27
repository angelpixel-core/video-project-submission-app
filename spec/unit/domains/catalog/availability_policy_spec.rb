require "rails_helper"

RSpec.describe Catalog::Domain::Policies::AvailabilityPolicy do
  it "delegates to capacity and enforces the requested quantity" do
    offer = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")

    allow(Capacity::Domain::Policies::CapacityCalculationPolicy).to receive(:available_units_for).with(offer).and_return(2)

    expect(described_class.available?(offer, quantity: 2)).to be(true)
    expect(described_class.available?(offer, quantity: 3)).to be(false)
  end
end
