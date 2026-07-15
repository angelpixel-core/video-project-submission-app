require "rails_helper"

RSpec.describe Project do
  it "is an ActiveRecord model" do
    expect(described_class.superclass).to eq(ApplicationRecord)
  end

  it "belongs to a client and pm and starts as draft" do
    client = Client.create!(name: "Client", email: "client@example.com")
    pm = Pm.create!(name: "PM", email: "pm@example.com")
    project = described_class.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov")

    expect(project.status).to eq("draft")
    expect(project.client).to eq(client)
    expect(project.pm).to eq(pm)
  end
end
