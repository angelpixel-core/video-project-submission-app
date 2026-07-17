require "rails_helper"

RSpec.describe Project do
  it "is an ActiveRecord model" do
    expect(described_class.superclass).to eq(ApplicationRecord)
  end

  it "belongs to a client and pm and starts as draft" do
    client = Client.create!(name: "Client", email: "client@example.com")
    pm = Pm.create!(name: "PM", email: "pm@example.com")
    project = described_class.create!(client: client, pm: pm, status: :draft)

    expect(project.status).to eq("draft")
    expect(project.client).to eq(client)
    expect(project.pm).to eq(pm)
  end

  it "requires submission fields once submitted" do
    client = Client.create!(name: "Client", email: "client@example.com")
    pm = Pm.create!(name: "PM", email: "pm@example.com")
    project = described_class.new(client: client, pm: pm, status: :draft)

    expect(project).to be_valid

    project.status = :pending

    expect(project).not_to be_valid
    expect(project.errors[:name]).to be_present
    expect(project.errors[:raw_footage_url]).to be_present
  end

  it "moves through the project lifecycle" do
    client = Client.create!(name: "Client", email: "client@example.com")
    pm = Pm.create!(name: "PM", email: "pm@example.com")
    project = described_class.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :draft)

    project.submit!
    expect(project.status).to eq("pending")

    project.accept!
    expect(project.status).to eq("in_progress")

    project.complete!
    expect(project.status).to eq("completed")
  end
end
