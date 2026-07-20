require "rails_helper"

def switch_workspace_to(mode)
  find(".account-menu-trigger").click
  click_button "Switch to #{mode}"
end

RSpec.describe "PM notifications", type: :system, js: true do
  include ActiveSupport::Testing::TimeHelpers

  before do
    driven_by :selenium_chrome_headless

    Client.create!(name: "Default Client", email: "client@example.com")
    PM.create!(name: "Default PM", email: "pm@example.com")
    VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    VideoType.create!(name: "Social Cut", description: "Social edit", price_cents: 15_000, output_format: "mp4")
  end

  it "shows unread notifications and lets the pm acknowledge them" do
    client = Client.find_by!(email: "client@example.com")
    pm = PM.find_by!(email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project Alpha", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
    notification = Notification.create!(project: project, pm: pm, kind: "project_created", body: "Unread PM notification")
    Notification.create!(project: project, pm: pm, kind: "project_created", body: "Second unread notification")
    Notification.create!(project: project, pm: pm, kind: "project_created", body: "Third unread notification")

    visit projects_path

    switch_workspace_to("PM")
    find("#pm-notifications-dropdown button").click

    expect(page).to have_css("#pm-notifications-dropdown .dropdown-menu.show")
    expect(page).to have_css("#pm-notifications-panel")
    expect(page).to have_css(".pm-notification-row", text: "Unread PM notification")
    expect(page).to have_css(".pm-notification-row", text: "Second unread notification")

    within(first(".pm-notification-row", text: "Unread PM notification")) do
      click_link "Project Alpha"
    end

    expect(page).to have_current_path(project_path(project))
    expect(page).to have_content("PROJECT DETAIL")
    expect(notification.reload.read_at).to be_present

    visit projects_path

    find("#pm-notifications-dropdown button").click

    within(first(".pm-notification-row", text: "Second unread notification")) do
      find("button[aria-label='Mark as read']").click
    end

    expect(page).to have_css("#pm-notifications-dropdown .dropdown-menu.show")
    expect(page).to have_no_css(".pm-notification-row", text: "Unread PM notification")
    expect(page).to have_no_css(".pm-notification-row", text: "Second unread notification")
    expect(page).to have_css(".pm-notification-row", text: "Third unread notification")

    expect(page).to have_current_path(projects_path)
    expect(page).to have_no_content("Unread PM notification")
    expect(notification.reload.read_at).to be_present
  end

  it "marks a pm toast as read when the project link is clicked" do
    client = Client.find_by!(email: "client@example.com")
    pm = PM.find_by!(email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project Toast", raw_footage_url: "https://example.com/toast.mov", status: :in_progress)
    notification = Notification.create!(project: project, pm: pm, kind: "project_created", body: "Unread PM notification")

    visit projects_path

    switch_workspace_to("PM")

    within(first("#pm-notifications-panel .pm-notification-toast")) do
      click_link "Project Toast"
    end

    expect(page).to have_current_path(project_path(project))
    expect(notification.reload.read_at).to be_present
  end

  it "updates pm workspace project actions without a full reload" do
    client = Client.find_by!(email: "client@example.com")
    pm = PM.find_by!(email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project Beta", raw_footage_url: "https://example.com/beta.mov", status: :pending)
    project.video_type_selections.create!(video_type: VideoType.find_by!(name: "Highlight Reel"), quantity: 2)

    visit projects_path

    switch_workspace_to("PM")

    page.execute_script("window.__pmActionSentinel = 1")

    expect(page).to have_content("PM WORKSPACE")
    expect(page).to have_content("Default PM projects")
    expect(page).to have_no_content("CLIENT WORKSPACE")
    expect(page).to have_content("Created at")
    expect(page).to have_content("Total budget")
    expect(page).to have_css("table.pm-projects-table")
    expect(page).to have_css("tbody#pm-projects-table-body tr", text: "Project Beta")
    expect(page).to have_content("$500.00")
    expect(page).to have_button("Aceptar proyecto")
    expect(page).not_to have_button("Marcar como completado")

    click_button "Aceptar proyecto"

    expect(page.evaluate_script("window.__pmActionSentinel")).to eq(1)
    expect(page).to have_current_path(projects_path, ignore_query: false)
    expect(page).to have_css("tbody#pm-projects-table-body tr", text: "Project Beta")
    expect(page).to have_content("EN PROGRESO")
    expect(page).to have_button("Marcar como completado")

    click_button "Marcar como completado"

    expect(page.evaluate_script("window.__pmActionSentinel")).to eq(1)
    expect(page).to have_current_path(projects_path, ignore_query: false)
    expect(page).to have_css("tbody#pm-projects-table-body tr", text: "Project Beta")
    expect(page).to have_content("COMPLETADO")
    expect(page).not_to have_button("Aceptar proyecto")
    expect(page).not_to have_button("Marcar como completado")
  end

  it "keeps the current page when sorting the pm table" do
    client = Client.find_by!(email: "client@example.com")
    pm = PM.find_by!(email: "pm@example.com")

    11.times do |index|
      travel_to (10 - index).minutes.ago do
        Project.create!(client: client, pm: pm, name: "Project #{index + 1}", raw_footage_url: "https://example.com/#{index + 1}.mov", status: :pending)
      end
    end

    visit projects_path(page: 2)

    switch_workspace_to("PM")

    click_link "ID"

    expect(page).to have_current_path(projects_path(page: 2, sort: "id", direction: "desc"), ignore_query: false)
    expect(page).to have_css(".pm-table-sort-link.is-active[aria-current='true']")
    expect(page).to have_css(".pm-table-sort-link.is-active .pm-table-sort-arrow.is-active", text: "↓")

    click_link "ID"

    expect(page).to have_current_path(projects_path(page: 2, sort: "id", direction: "asc"), ignore_query: false)
    expect(page).to have_css(".pm-table-sort-link.is-active[aria-current='true']")
    expect(page).to have_css(".pm-table-sort-link.is-active .pm-table-sort-arrow.is-active", text: "↑")

    click_link "ID"

    expect(page).to have_current_path(projects_path(page: 2), ignore_query: false)
  end

  it "lets the pm navigate between project pages" do
    client = Client.find_by!(email: "client@example.com")
    pm = PM.find_by!(email: "pm@example.com")

    11.times do |index|
      travel_to (10 - index).minutes.ago do
        Project.create!(client: client, pm: pm, name: "Project #{index + 1}", raw_footage_url: "https://example.com/#{index + 1}.mov", status: :pending)
      end
    end

    visit projects_path

    switch_workspace_to("PM")

    expect(page).to have_css("nav[aria-label='PM projects pagination']")
    expect(page).to have_link("2")

    click_link "2"

    expect(page).to have_current_path(projects_path(page: 2, sort: "created_at", direction: "desc"), ignore_query: false)
    expect(page).to have_css("tbody#pm-projects-table-body tr", text: "Project 1")
    expect(page).to have_no_css("tbody#pm-projects-table-body tr", text: "Project 11")
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
    highlight_reel = VideoType.find_by!(name: "Highlight Reel")

    using_session(:pm) do
      visit projects_path
      switch_workspace_to("PM")

      find("#pm-notifications-dropdown button").click

      expect(page).to have_css("#pm-notifications-dropdown .dropdown-menu.show", visible: :visible)
      expect(page).to have_css('html[data-pm-notifications-connected="true"]')
      expect(page).to have_no_css(".pm-notification-item")
      expect(page).to have_css("table.pm-projects-table")
      expect(page).to have_css("tbody#pm-projects-table-body tr", text: "No projects yet.")
    end

    Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do
        project.update!(name: "Project Gamma", raw_footage_url: "https://example.com/gamma.mov")
        project.video_type_selections.create!(video_type: highlight_reel, quantity: 2)
        project.submit!
        Notification.create!(project: project, pm: pm, kind: "project_created", body: notification_body)
      end
    end.join

    using_session(:pm) do
      expect(page).to have_css(".pm-notification-item", text: notification_body)
      expect(page).to have_css("tbody#pm-projects-table-body tr", text: "Project Gamma")
    end

    Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do
        Notification.find_by!(project_id: project.id, pm_id: pm.id, body: notification_body).mark_as_read!
      end
    end.join

    using_session(:pm) do
      expect(page).to have_css("#pm-notifications-panel")
      expect(page).to have_no_css(".pm-notification-item", text: notification_body)
    end
  end
end
