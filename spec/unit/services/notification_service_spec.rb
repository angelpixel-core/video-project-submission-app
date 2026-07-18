require "rails_helper"

RSpec.describe NotificationService do
  it "logs a message for the project's pm" do
    client = Client.create!(name: "Client", email: "client@example.com")
    pm = PM.create!(name: "PM", email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    channel = instance_double(NotificationDelivery::LoggerChannel)
    expect(NotificationDelivery::LoggerChannel).to receive(:new).with(project).and_return(channel)
    expect(channel).to receive(:call)

    described_class.new(project.id).call
  end
end
