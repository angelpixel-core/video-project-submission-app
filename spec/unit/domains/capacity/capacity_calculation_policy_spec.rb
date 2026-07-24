require "rails_helper"

RSpec.describe Capacity::Domain::Policies::CapacityCalculationPolicy do
  it "reserves capacity based on active projects" do
    offer = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    client = client_account(name: "Client")
    pm = pm_account(name: "PM")
    project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    project.video_type_selections.create!(video_type: offer, quantity: 2)

    allow(ENV).to receive(:fetch).with("CAPACITY_TOTAL_UNITS", 100).and_return("3")

    expect(described_class.available_units_for(offer)).to eq(1)
  end
end
