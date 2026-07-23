require "rails_helper"

RSpec.describe Projects::Notifications::LoggerChannel do
  it "logs a message for the project's pm" do
    client = Client.create!(name: "Client", email: "client@example.com")
    pm = PM.create!(name: "PM", email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    expect(Rails.logger).to receive(:info).with("Notification for PM pm@example.com: project #{project.id} was created")

    described_class.new(project).call
  end
end
