require "rails_helper"

RSpec.describe Projects::Notifications::Dispatcher do
  it "delivers project_created emails to client and pm" do
    client = client_account(name: "Client")
    pm = pm_account(name: "PM")
    project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    client_mail = instance_double(ActionMailer::MessageDelivery)
    pm_mail = instance_double(ActionMailer::MessageDelivery)

    expect(ClientNotificationMailer).to receive(:project_created).with(project).and_return(client_mail)
    expect(PMNotificationMailer).to receive(:project_created).with(project).and_return(pm_mail)
    expect(client_mail).to receive(:deliver_now)
    expect(pm_mail).to receive(:deliver_now)

    described_class.call(project: project, event_type: :project_created)
  end

  it "delivers project_accepted emails to client and pm" do
    client = client_account(name: "Client")
    pm = pm_account(name: "PM")
    project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    client_mail = instance_double(ActionMailer::MessageDelivery)
    pm_mail = instance_double(ActionMailer::MessageDelivery)

    expect(ClientNotificationMailer).to receive(:project_accepted).with(project).and_return(client_mail)
    expect(PMNotificationMailer).to receive(:project_accepted).with(project).and_return(pm_mail)
    expect(client_mail).to receive(:deliver_now)
    expect(pm_mail).to receive(:deliver_now)

    described_class.call(project: project, event_type: :project_accepted)
  end
end
