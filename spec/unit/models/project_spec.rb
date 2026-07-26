require "rails_helper"

RSpec.describe Project do
  it "is an ActiveRecord model" do
    expect(described_class.superclass).to eq(ApplicationRecord)
  end

  it "belongs to an owner and participant and starts as draft" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = described_class.create!(owner: client, participant: pm, status: :draft)

    expect(project.status).to eq("draft")
    expect(project.owner).to eq(client)
    expect(project.participant).to eq(pm)
  end

  it "keeps account ids populated when using the neutral associations" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")

    project = described_class.create!(owner: client, participant: pm, status: :draft)

    expect(project.owner_account_id).to eq(client.id)
    expect(project.participant_account_id).to eq(pm.id)
  end

  it "requires submission fields once submitted" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = described_class.new(owner: client, participant: pm, status: :draft)

    expect(project).to be_valid

    project.status = :pending

    expect(project).not_to be_valid
    expect(project.errors[:name]).to be_present
    expect(project.errors[:raw_footage_url]).to be_present
  end

  it "derives raw footage metadata for recognized urls" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = described_class.create!(owner: client, participant: pm, status: :draft, raw_footage_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")

    expect(project.raw_footage_metadata_hash).to include(
      "provider" => "youtube",
      "video_id" => "dQw4w9WgXcQ"
    )
    expect(project.raw_footage_previewable?).to be(true)
  end

  it "derives vimeo metadata when the url is recognized" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = described_class.create!(owner: client, participant: pm, status: :draft, raw_footage_url: "https://vimeo.com/123456789")

    expect(project.raw_footage_metadata_hash).to include(
      "provider" => "vimeo",
      "video_id" => "123456789"
    )
  end

  it "moves through the project lifecycle" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = described_class.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :draft)

    project.submit!
    expect(project.status).to eq("pending")

    project.accept!
    expect(project.status).to eq("in_progress")

    project.complete!
    expect(project.status).to eq("completed")
  end

  it "sums the project budget from selections" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = described_class.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    highlight_reel = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    social_cut = VideoType.create!(name: "Social Cut", description: "Social edit", price_cents: 15_000, output_format: "mp4")

    project.video_type_selections.create!(video_type: highlight_reel, quantity: 2)
    project.video_type_selections.create!(video_type: social_cut, quantity: 1)

    expect(project.total_budget_cents).to eq(65_000)
  end

  it "rejects invalid lifecycle jumps" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = described_class.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :draft)

    expect { project.accept! }.to raise_error(AASM::InvalidTransition)
  end
end
