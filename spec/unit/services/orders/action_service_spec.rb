require "rails_helper"

RSpec.describe Orders::ActionService do
  it "accepts a pending project, marks unread pm notifications as read, and creates a client notification" do
    client = workspace_account(:client, email: "client@example.com", name: "Client")
    pm = workspace_account(:pm, email: "pm@example.com", name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project Pending", raw_footage_url: "https://example.com/pending.mov", status: :pending)
    unread_notification = Notification.create!(project: project, pm: pm, kind: "project_created", body: "Unread PM notification")

    client_mail = instance_double(ActionMailer::MessageDelivery, deliver_now: true)
    pm_mail = instance_double(ActionMailer::MessageDelivery, deliver_now: true)
    expect(ProjectNotificationMailer).to receive(:project_accepted).with(project, recipient_role: :client).and_return(client_mail)
    expect(ProjectNotificationMailer).to receive(:project_accepted).with(project, recipient_role: :pm).and_return(pm_mail)

    result = described_class.call(project: project, event: :accept)

    expect(result).to be_success
    expect(result.data.fetch(:broadcast_refresh)).to be(true)
    expect(project.reload.status).to eq("in_progress")
    expect(unread_notification.reload.read_at).to be_present
    expect(Notification.where(project: project, kind: "project_accepted")).to exist
  end

  it "completes an in-progress project and creates a client notification" do
    client = workspace_account(:client, email: "client@example.com", name: "Client")
    pm = workspace_account(:pm, email: "pm@example.com", name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project Active", raw_footage_url: "https://example.com/active.mov", status: :in_progress)

    client_mail = instance_double(ActionMailer::MessageDelivery, deliver_now: true)
    pm_mail = instance_double(ActionMailer::MessageDelivery, deliver_now: true)
    expect(ProjectNotificationMailer).to receive(:project_completed).with(project, recipient_role: :client).and_return(client_mail)
    expect(ProjectNotificationMailer).to receive(:project_completed).with(project, recipient_role: :pm).and_return(pm_mail)

    result = described_class.call(project: project, event: :complete)

    expect(result).to be_success
    expect(result.data.fetch(:broadcast_refresh)).to be(false)
    expect(project.reload.status).to eq("completed")
    expect(Notification.where(project: project, kind: "project_completed")).to exist
  end

  it "returns a failure for stale actions" do
    project = Project.create!(owner: workspace_account(:client, email: "client@example.com", name: "Client"), participant: workspace_account(:pm, email: "pm@example.com", name: "PM"), name: "Project Draft", raw_footage_url: "https://example.com/draft.mov", status: :draft)

    result = described_class.call(project: project, event: :complete)

    expect(result).to be_failure
    expect(result.code).to eq(:invalid_transition)
  end
end
