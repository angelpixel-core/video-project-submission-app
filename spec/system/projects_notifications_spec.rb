require "rails_helper"

RSpec.describe "PM notifications", type: :system do
  before do
    driven_by :rack_test

    Client.create!(name: "Default Client", email: "client@example.com")
    PM.create!(name: "Default PM", email: "pm@example.com")
  end

  it "shows unread notifications and lets the pm acknowledge them" do
    client = Client.find_by!(email: "client@example.com")
    pm = PM.find_by!(email: "pm@example.com")
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
    pm = PM.find_by!(email: "pm@example.com")
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

RSpec.describe "PM notifications realtime", type: :system, js: true do
  include ActiveJob::TestHelper

  before do
    driven_by :selenium_chrome_headless

    Client.create!(name: "Default Client", email: "client@example.com")
    PM.create!(name: "Default PM", email: "pm@example.com")
    VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
  end

  it "refreshes the inbox when a notification is created or acknowledged" do
    client = Client.find_by!(email: "client@example.com")
    pm = PM.find_by!(email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, status: :draft)
    notification_body = "Project Gamma submitted for review"

    using_session(:pm) do
      visit projects_path
      click_button "PM"

      expect(page).to have_css("#pm-notifications-panel", visible: :visible)
      expect(page).to have_css('html[data-pm-notifications-connected="true"]')
      expect(page).to have_content("No unread notifications yet.")
    end

    Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do
        Notification.create!(
          project: project,
          pm: pm,
          kind: "project_created",
          body: notification_body
        )
      end
    end.join

    using_session(:pm) do
      expect(page).to have_content(notification_body)
      expect(page).to have_no_content("No unread notifications yet.")
    end

    Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do
        Notification.find_by!(project_id: project.id, pm_id: pm.id, body: notification_body).mark_as_read!
      end
    end.join

    using_session(:pm) do
      expect(page).to have_content("No unread notifications yet.")
      expect(page).to have_no_content(notification_body)
    end
  end
end
