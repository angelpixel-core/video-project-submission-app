require "rails_helper"

RSpec.describe Projects::Notifications::Channel::Email do
  it "delivers the project status emails to client and pm" do
    client = Client.create!(name: "Client", email: "client@example.com")
    pm = PM.create!(name: "PM", email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    client_mail = instance_double(ActionMailer::MessageDelivery)
    pm_mail = instance_double(ActionMailer::MessageDelivery)

    expect(ClientNotificationMailer).to receive(:project_created).with(project).and_return(client_mail)
    expect(PMNotificationMailer).to receive(:project_created).with(project).and_return(pm_mail)
    expect(client_mail).to receive(:deliver_now)
    expect(pm_mail).to receive(:deliver_now)

    described_class.new(project, :project_created).call
  end
end
