require "rails_helper"

RSpec.describe Projects::Notifications::Channel::Logger do
  it "logs a message for the project's pm" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    expect(Rails.logger).to receive(:info).with("Notification for participant pm@example.com: project #{project.id} was created")

    described_class.new(project).call
  end
end
