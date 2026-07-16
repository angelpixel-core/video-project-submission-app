require "rails_helper"

RSpec.describe NotificationService do
  it "logs a message for the project's pm" do
    client = Client.create!(name: "Client", email: "client@example.com")
    pm = Pm.create!(name: "PM", email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    expect(Rails.logger).to receive(:info).with("Notification for PM pm@example.com: project #{project.id} was created")

    described_class.new(project.id).call
  end
end
