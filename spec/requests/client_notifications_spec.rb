require "rails_helper"

RSpec.describe "Client notifications requests" do
  before do
    Client.create!(name: "Default Client", email: "client@example.com")
    PM.create!(name: "Default PM", email: "pm@example.com")
  end

  it "marks a client notification as read" do
    client = Client.find_by!(email: "client@example.com")
    pm = PM.find_by!(email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project Alpha", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
    notification = Notification.create!(project: project, client: client, kind: "project_status_changed", body: "Project updated")

    patch client_notification_path(notification)

    expect(response).to have_http_status(:no_content)
    expect(notification.reload.read_at).to be_present
  end
end
