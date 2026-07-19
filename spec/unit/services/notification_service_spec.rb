require "rails_helper"

RSpec.describe NotificationService do
  it "creates a notification and logs a message for the project's pm" do
    client = Client.create!(name: "Client", email: "client@example.com")
    pm = PM.create!(name: "PM", email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    logger_channel = instance_double(NotificationDelivery::LoggerChannel)
    email_channel = instance_double(NotificationDelivery::EmailChannel)
    expect(NotificationDelivery::LoggerChannel).to receive(:new).with(project).and_return(logger_channel)
    expect(NotificationDelivery::EmailChannel).to receive(:new).with(project).and_return(email_channel)
    expect(logger_channel).to receive(:call)
    expect(email_channel).to receive(:call)

    expect do
      described_class.new(project.id).call
    end.to change(Notification, :count).by(1)
  end
end
