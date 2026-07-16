require "rails_helper"

RSpec.describe NotificationJob do
  it "delegates to the notification service" do
    project = Project.create!(
      client: Client.create!(name: "Client", email: "client@example.com"),
      pm: Pm.create!(name: "PM", email: "pm@example.com"),
      name: "Project",
      raw_footage_url: "https://example.com/raw.mov",
      status: :in_progress
    )

    service = instance_double(NotificationService)
    expect(NotificationService).to receive(:new).with(project.id).and_return(service)
    expect(service).to receive(:call)

    described_class.perform_now(project.id)
  end
end
