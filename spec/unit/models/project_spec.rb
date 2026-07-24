require "rails_helper"

RSpec.describe Project do
  it "is an ActiveRecord model" do
    expect(described_class.superclass).to eq(ApplicationRecord)
  end

  it "belongs to a client and pm and starts as draft" do
    client = client_account(name: "Client")
    pm = pm_account(name: "PM")
    project = described_class.create!(client: client, pm: pm, status: :draft)

    expect(project.status).to eq("draft")
    expect(project.client).to eq(client)
    expect(project.pm).to eq(pm)
  end

  it "keeps legacy identity ids populated when using account-backed associations" do
    client = client_account(name: "Client")
    pm = pm_account(name: "PM")

    project = described_class.create!(client_account: client, pm_account: pm, status: :draft)

    expect(project.client_id).to eq(client.id)
    expect(project.pm_id).to eq(pm.id)
  end

  it "requires submission fields once submitted" do
    client = client_account(name: "Client")
    pm = pm_account(name: "PM")
    project = described_class.new(client: client, pm: pm, status: :draft)

    expect(project).to be_valid

    project.status = :pending

    expect(project).not_to be_valid
    expect(project.errors[:name]).to be_present
    expect(project.errors[:raw_footage_url]).to be_present
  end

  it "derives raw footage metadata for recognized urls" do
    client = client_account(name: "Client")
    pm = pm_account(name: "PM")
    project = described_class.create!(client: client, pm: pm, status: :draft, raw_footage_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")

    expect(project.raw_footage_metadata_hash).to include(
      "provider" => "youtube",
      "video_id" => "dQw4w9WgXcQ"
    )
    expect(project.raw_footage_previewable?).to be(true)
  end

  it "derives vimeo metadata when the url is recognized" do
    client = client_account(name: "Client")
    pm = pm_account(name: "PM")
    project = described_class.create!(client: client, pm: pm, status: :draft, raw_footage_url: "https://vimeo.com/123456789")

    expect(project.raw_footage_metadata_hash).to include(
      "provider" => "vimeo",
      "video_id" => "123456789"
    )
  end

  it "moves through the project lifecycle" do
    client = client_account(name: "Client")
    pm = pm_account(name: "PM")
    project = described_class.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :draft)

    project.submit!
    expect(project.status).to eq("pending")

    project.accept!
    expect(project.status).to eq("in_progress")

    project.complete!
    expect(project.status).to eq("completed")
  end

  it "sums the project budget from selections" do
    client = client_account(name: "Client")
    pm = pm_account(name: "PM")
    project = described_class.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    highlight_reel = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    social_cut = VideoType.create!(name: "Social Cut", description: "Social edit", price_cents: 15_000, output_format: "mp4")

    project.video_type_selections.create!(video_type: highlight_reel, quantity: 2)
    project.video_type_selections.create!(video_type: social_cut, quantity: 1)

    expect(project.total_budget_cents).to eq(65_000)
  end

  it "rejects invalid lifecycle jumps" do
    client = client_account(name: "Client")
    pm = pm_account(name: "PM")
    project = described_class.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :draft)

    expect { project.accept! }.to raise_error(AASM::InvalidTransition)
  end
end
