require "rails_helper"

RSpec.describe Projects::NotificationService do
  it "creates a notification and delivers project_created emails to client and pm" do
    client = Client.create!(name: "Client", email: "client@example.com")
    pm = PM.create!(name: "PM", email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    logger_channel = instance_double(Projects::Notifications::LoggerChannel)
    expect(Projects::Notifications::LoggerChannel).to receive(:new).with(project).and_return(logger_channel)
    expect(Projects::Notifications::Delivery).to receive(:call).with(project: project, event_type: :project_created)
    expect(logger_channel).to receive(:call)

    expect do
      described_class.new(project.id).call
    end.to change(Notification, :count).by(1)
  end
end
