require "rails_helper"

RSpec.describe NotificationJob do
  it "delegates to the notification service" do
    project = Project.create!(
      owner: workspace_account(:client, name: "Client"),
      participant: workspace_account(:pm, name: "PM"),
      name: "Project",
      raw_footage_url: "https://example.com/raw.mov",
      status: :in_progress
    )

    service = instance_double(Projects::Notifications::Service)
    expect(Projects::Notifications::Service).to receive(:new).with(project.id).and_return(service)
    expect(service).to receive(:call)

    described_class.perform_now(project.id)
  end
end
