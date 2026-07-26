require "rails_helper"

RSpec.describe Projects::Notifications::Service do
  it "creates a notification and delivers project_created emails to client and pm" do
    client = client_account(name: "Client")
    pm = pm_account(name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    expect(Projects::Notifications::Dispatcher).to receive(:call).with(project: project, event_type: :project_created)

    expect do
      described_class.new(project.id).call
    end.to change(Notification, :count).by(1)
  end
end
