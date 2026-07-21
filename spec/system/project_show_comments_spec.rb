require "rails_helper"

def switch_workspace_to(mode)
  find(".account-menu-trigger").click
  click_button "Switch to #{mode}"
end

RSpec.describe "Project show comments", type: :system, js: true do
  before do
    driven_by :selenium_chrome_headless

    Client.create!(name: "Default Client", email: "client@example.com")
    PM.create!(name: "Default PM", email: "pm@example.com")
    VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
  end

  it "shows a raw footage embed and allows both workspaces to comment" do
    client = Client.find_by!(email: "client@example.com")
    pm = PM.find_by!(email: "pm@example.com")
    project = Project.create!(
      client: client,
      pm: pm,
      name: "Project Alpha",
      raw_footage_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      status: :in_progress
    )

    visit project_path(project)

    expect(page).to have_css("iframe[src*='youtube-nocookie.com/embed/dQw4w9WgXcQ']")
    expect(page).to have_content("No comments yet.")

    fill_in "Message", with: "Client note"
    click_button "Post comment"

    expect(page).to have_content("Comment posted.")
    expect(page).to have_css("#project-comments", text: "Client note")
    expect(page).to have_css("#project-comments .badge", text: "CLIENT")

    switch_workspace_to("PM")
    visit project_path(project)

    fill_in "Message", with: "PM reply"
    click_button "Post comment"

    expect(page).to have_css("#project-comments", text: "PM reply")
    expect(page).to have_css("#project-comments .badge", text: "PM")
  end

  it "refreshes comments and notifications across workspaces in realtime" do
    client = Client.find_by!(email: "client@example.com")
    pm = PM.find_by!(email: "pm@example.com")
    project = Project.create!(
      client: client,
      pm: pm,
      name: "Project Gamma",
      raw_footage_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      status: :in_progress
    )

    using_session(:pm) do
      visit project_path(project)
      switch_workspace_to("PM")

      expect(page).to have_content("No comments yet.")
      expect(page).to have_css('#pm-notifications-dropdown .pm-notifications-badge', text: "0")
    end

    using_session(:client) do
      visit project_path(project)
      fill_in "Message", with: "Client realtime note"
      click_button "Post comment"
      expect(page).to have_content("Comment posted.")
    end

    using_session(:pm) do
      expect(page).to have_css("#project-comments", text: "Client realtime note")
      expect(page).to have_css('#pm-notifications-dropdown .pm-notifications-badge', text: "1")
      expect(page).to have_no_css('#pm-notifications-panel .pm-notification-toast', text: "Client realtime note")
    end
  end

  it "shows a raw footage preview on the client project card" do
    client = Client.find_by!(email: "client@example.com")
    pm = PM.find_by!(email: "pm@example.com")
    Project.create!(
      client: client,
      pm: pm,
      name: "Project Beta",
      raw_footage_url: "https://youtu.be/dQw4w9WgXcQ",
      status: :pending
    )

    visit projects_path

    expect(page).to have_css(".client-project-card .youtube-preview img[src*='img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg']")
    expect(page).to have_link("View details", href: project_path(Project.find_by!(name: "Project Beta")))
    expect(page).to have_link("Play preview", href: project_path(Project.find_by!(name: "Project Beta")))

    click_link "View details"

    expect(page).to have_current_path(project_path(Project.find_by!(name: "Project Beta")))
    expect(page).to have_content("PROJECT DETAIL")
    expect(page).to have_content("Comments")
  end
end
