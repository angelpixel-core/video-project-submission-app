require "rails_helper"

RSpec.describe Notification do
  it "is an ActiveRecord model" do
    expect(described_class.superclass).to eq(ApplicationRecord)
  end

  it "requires a project, pm, kind, and body" do
    notification = described_class.new

    expect(notification).not_to be_valid
    expect(notification.errors[:project]).to be_present
    expect(notification.errors[:pm]).to be_present
    expect(notification.errors[:client]).to be_present
    expect(notification.errors[:kind]).to be_present
    expect(notification.errors[:body]).to be_present
  end

  it "requires exactly one recipient" do
    client = Client.create!(name: "Client", email: "client@example.com")
    pm = PM.create!(name: "PM", email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    with_only_pm = described_class.new(project: project, pm: pm, kind: "project_created", body: "Project created")
    expect(with_only_pm).to be_valid

    with_only_client = described_class.new(project: project, client: client, kind: "project_status_changed", body: "Project updated")
    expect(with_only_client).to be_valid

    with_both = described_class.new(project: project, pm: pm, client: client, kind: "project_status_changed", body: "Project updated")
    expect(with_both).not_to be_valid
    expect(with_both.errors[:base]).to include("Notification recipient must be exclusive")
  end

  it "defaults to unread and can be marked as read" do
    client = Client.create!(name: "Client", email: "client@example.com")
    pm = PM.create!(name: "PM", email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
    notification = described_class.create!(project: project, pm: pm, kind: "project_created", body: "Project created")

    expect(described_class.unread).to include(notification)
    expect(described_class.read).not_to include(notification)

    notification.mark_as_read!

    expect(notification.read_at).to be_present
    expect(described_class.read).to include(notification)
    expect(described_class.unread).not_to include(notification)
  end

  it "broadcasts refreshes to the recipient stream" do
    client = Client.create!(name: "Client", email: "client@example.com")
    pm = PM.create!(name: "PM", email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    expect(ActionCable.server).to receive(:broadcast).with(
      "client_notifications",
      hash_including(type: "notifications_updated", project_id: project.id, kind: "project_status_changed")
    )
    described_class.create!(project: project, client: client, kind: "project_status_changed", body: "Project updated")
  end
end
