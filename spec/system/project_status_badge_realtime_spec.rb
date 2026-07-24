require "rails_helper"

RSpec.describe "Project status badge realtime", type: :system, js: true do
  def switch_workspace_to(mode)
    find(".account-menu-trigger").click
    click_button "Switch to #{mode}"
  end

  around do |example|
    original_client = ENV["DEFAULT_CLIENT_EMAIL"]
    original_pm = ENV["DEFAULT_PM_EMAIL"]

    ENV["DEFAULT_CLIENT_EMAIL"] = "client@example.com"
    ENV["DEFAULT_PM_EMAIL"] = "pm@example.com"

    example.run
  ensure
    ENV["DEFAULT_CLIENT_EMAIL"] = original_client
    ENV["DEFAULT_PM_EMAIL"] = original_pm
  end

  before do
    driven_by :selenium_chrome_headless

    client_account(name: "Default Client")
    pm_account(name: "Default PM")
    VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
  end

  it "updates the client project badge when the pm changes the status" do
    client = find_client_account
    pm = find_pm_account
    project = Project.create!(client: client, pm: pm, name: "Project Alpha", raw_footage_url: "https://example.com/raw.mov", status: :pending)

    using_session(:client) do
      visit projects_path

      expect(page).to have_css("##{project.status_badge_dom_id}", text: "PENDIENTE")
      expect(page).to have_css("html[data-role-mode='client']")
      expect(page).to have_css("html[data-project-status-connected='true']")
    end

    using_session(:pm) do
      visit project_path(project)
      switch_workspace_to("PM")
      click_button "Aceptar proyecto"
    end

    using_session(:client) do
      expect(page).to have_css("##{project.status_badge_dom_id}", text: "EN PROGRESO")
    end
  end
end
