require "rails_helper"

RSpec.describe "PM notifications", type: :system do
  before do
    driven_by :rack_test

    Client.create!(name: "Default Client", email: "client@example.com")
    Pm.create!(name: "Default PM", email: "pm@example.com")
  end

  it "shows unread notifications and lets the pm acknowledge them" do
    client = Client.find_by!(email: "client@example.com")
    pm = Pm.find_by!(email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project Alpha", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
    notification = Notification.create!(project: project, pm: pm, kind: "project_created", body: "Unread PM notification")

    visit projects_path

    expect(page).to have_content("PM inbox")
    expect(page).to have_content("Unread PM notification")

    click_button "Mark as read"

    expect(page).to have_current_path(projects_path)
    expect(page).not_to have_content("Unread PM notification")
    expect(notification.reload.read_at).to be_present
  end
end
