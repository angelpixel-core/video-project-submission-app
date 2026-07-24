require "rails_helper"

RSpec.describe "Client notifications requests" do
  around do |example|
    original_client = ENV["DEFAULT_CLIENT_EMAIL"]
    original_pm = ENV["DEFAULT_PM_EMAIL"]

    ENV["DEFAULT_CLIENT_EMAIL"] = "client@example.com"
    ENV["DEFAULT_PM_EMAIL"] = "pm@example.com"

    example.run

    restore_env("DEFAULT_CLIENT_EMAIL", original_client)
    restore_env("DEFAULT_PM_EMAIL", original_pm)
  end

  before do
    client_account(name: "Default Client")
    pm_account(name: "Default PM")
  end

  def restore_env(key, value)
    if value.nil?
      ENV.delete(key)
    else
      ENV[key] = value
    end
  end

  it "marks a client notification as read" do
    client = find_client_account
    pm = find_pm_account
    project = Project.create!(client: client, pm: pm, name: "Project Alpha", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
    notification = Notification.create!(project: project, client: client, kind: "project_status_changed", body: "Project updated")

    patch client_notification_path(notification)

    expect(response).to have_http_status(:no_content)
    expect(notification.reload.read_at).to be_present
  end
end
