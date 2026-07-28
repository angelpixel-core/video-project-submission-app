require "rails_helper"

RSpec.describe ProjectNotificationSubject do
  it "builds the pm subject for accepted projects" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    subject = described_class.call(project: project, recipient_role: :pm, event_type: :project_accepted)

    expect(subject).to eq("Project accepted: Project")
  end

  it "builds the client subject for completed projects" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    subject = described_class.call(project: project, recipient_role: :client, event_type: :project_completed)

    expect(subject).to eq("Your project Project has been completed")
  end
end
