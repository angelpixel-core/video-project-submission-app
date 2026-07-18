require "rails_helper"

RSpec.describe VideoTypeSelection do
  it "is an ActiveRecord model" do
    expect(described_class.superclass).to eq(ApplicationRecord)
  end

  it "belongs to a project and a video type" do
    client = Client.create!(name: "Client", email: "client@example.com")
    pm = PM.create!(name: "PM", email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov")
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 10_000, output_format: "mp4")

    selection = described_class.create!(project: project, video_type: video_type, quantity: 2)

    expect(selection.project).to eq(project)
    expect(selection.video_type).to eq(video_type)
    expect(project.video_types).to contain_exactly(video_type)
  end
end
