require "rails_helper"

RSpec.describe Comment do
  it "requires a project, an author, and a body" do
    comment = described_class.new

    expect(comment).not_to be_valid
    expect(comment.errors[:project]).to be_present
    expect(comment.errors[:author]).to be_present
    expect(comment.errors[:body]).to be_present
  end

  it "broadcasts project comment refreshes after create" do
    client = Client.create!(name: "Client", email: "client@example.com")
    pm = PM.create!(name: "PM", email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    expect(ActionCable.server).to receive(:broadcast).with("project_comments_#{project.id}", { type: "comments_updated" })
    described_class.create!(project: project, author: client, body: "Hello")
  end
end
