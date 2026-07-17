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

  it "lets the pm accept and complete projects from the workspace" do
    client = Client.find_by!(email: "client@example.com")
    pm = Pm.find_by!(email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project Beta", raw_footage_url: "https://example.com/beta.mov", status: :pending)

    visit projects_path

    expect(page).to have_content("PM workspace")
    expect(page).to have_button("Aceptar proyecto")

    click_button "Aceptar proyecto"

    expect(page).to have_current_path(projects_path)
    expect(project.reload.status).to eq("in_progress")
    expect(page).to have_button("Marcar como completado")

    click_button "Marcar como completado"

    expect(page).to have_current_path(projects_path)
    expect(project.reload.status).to eq("completed")
  end
end
