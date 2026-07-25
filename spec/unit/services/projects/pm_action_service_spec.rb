require "rails_helper"

RSpec.describe Projects::PMActionService do
  it "accepts a pending project and marks unread pm notifications as read" do
    client = client_account
    pm = pm_account
    project = Project.create!(client: client, pm: pm, name: "Project Pending", raw_footage_url: "https://example.com/pending.mov", status: :pending)
    unread_notification = Notification.create!(project: project, pm: pm, kind: "project_created", body: "Unread PM notification")

    expect(Projects::Notifications::Dispatcher).to receive(:call).with(project: project, event_type: :project_accepted)

    result = described_class.call(project: project, event: :accept)

    expect(result).to be_success
    expect(result.data.fetch(:broadcast_refresh)).to be(true)
    expect(project.reload.status).to eq("in_progress")
    expect(unread_notification.reload.read_at).to be_present
    expect(Notification.where(project: project, kind: "project_accepted")).to exist
  end

  it "completes an in-progress project without requesting a broadcast refresh" do
    client = client_account
    pm = pm_account
    project = Project.create!(client: client, pm: pm, name: "Project Active", raw_footage_url: "https://example.com/active.mov", status: :in_progress)

    result = described_class.call(project: project, event: :complete)

    expect(result).to be_success
    expect(result.data.fetch(:broadcast_refresh)).to be(false)
    expect(project.reload.status).to eq("completed")
    expect(Notification.where(project: project, kind: "project_completed")).to exist
  end

  it "returns a failure for stale actions" do
    project = Project.create!(client: client_account, pm: pm_account, name: "Project Draft", raw_footage_url: "https://example.com/draft.mov", status: :draft)

    result = described_class.call(project: project, event: :complete)

    expect(result).to be_failure
    expect(result.code).to eq(:invalid_transition)
  end
end
