require "rails_helper"

RSpec.describe "Profile page", type: :system, js: true do
  before do
    driven_by :selenium_chrome_headless

    Client.create!(name: "Default Client", email: "client@example.com")
    PM.create!(name: "Default PM", email: "pm@example.com")
    VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
  end

  it "renders the current client profile and token controls" do
    visit projects_path

    find(".account-menu-trigger").click
    click_link "Profile"

    expect(page).to have_current_path(profile_path, ignore_query: false)
    expect(page).to have_content("Default Client")
    expect(page).to have_content("client@example.com")
    expect(page).to have_content("Client")
    expect(page).to have_css(".profile-avatar", text: "C")
    expect(page).to have_button("Show")
    expect(page).to have_button("Copy")

    click_button "Show"

    expect(page).to have_css(".profile-token-value", text: /client_demo_/)

    click_button "Copy"

    expect(page).to have_button("Copied")
  end

  it "renders the pm profile when workspace mode is pm" do
    visit projects_path

    find(".account-menu-trigger").click
    click_button "Switch to PM"

    visit profile_path

    expect(page).to have_content("Default PM")
    expect(page).to have_content("pm@example.com")
    expect(page).to have_content("Project Manager")
    expect(page).to have_css(".profile-avatar", text: "P")
  end
end
