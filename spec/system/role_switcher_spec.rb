require "rails_helper"

RSpec.describe "Role switcher", type: :system, js: true do
  before do
    driven_by :selenium_chrome_headless

    Client.create!(name: "Default Client", email: "client@example.com")
    PM.create!(name: "Default PM", email: "pm@example.com")
    VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    Project.create!(
      client: Client.find_by!(email: "client@example.com"),
      pm: PM.find_by!(email: "pm@example.com"),
      name: "Project Alpha",
      raw_footage_url: "https://example.com/raw.mov",
      status: :draft
    )
    Project.create!(
      client: Client.find_by!(email: "client@example.com"),
      pm: PM.find_by!(email: "pm@example.com"),
      name: "Project Beta",
      raw_footage_url: "https://example.com/beta.mov",
      status: :pending
    )
    Notification.create!(
      project: Project.find_by!(name: "Project Beta"),
      pm: PM.find_by!(email: "pm@example.com"),
      kind: "project_created",
      body: "Unread PM notification"
    )
  end

  it "persists the selected workspace mode in session storage and swaps the visible UI" do
    visit projects_path

    expect(page).to have_css('.account-menu-trigger')
    expect(page).to have_content("New Order")
    expect(page).to have_content("Project Alpha")

    find(".account-menu-trigger").click
    click_button "Switch to PM"

    expect(page.evaluate_script("sessionStorage.getItem('workspace-mode')")).to eq("pm")
    expect(page).to have_css('[data-role-scope="pm"]', visible: :visible)
    expect(page).to have_no_content("New Order")
    expect(page).to have_no_content("Project Alpha")

    visit new_project_path

    expect(page).to have_css('.account-menu-trigger')
    expect(page).to have_no_css('[data-role-scope="client"]', visible: :visible)

    find(".account-menu-trigger").click
    click_button "Switch to Client"

    expect(page.evaluate_script("sessionStorage.getItem('workspace-mode')")).to eq("client")
    expect(page).to have_css('[data-role-scope="client"]', visible: :visible)
    expect(page).to have_no_css('[data-role-scope="pm"]', visible: :visible)
  end
end
