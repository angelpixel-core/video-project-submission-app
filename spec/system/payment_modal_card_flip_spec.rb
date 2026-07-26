require "rails_helper"

RSpec.describe "Payment modal card flip", type: :system, js: true do
  before do
    driven_by :selenium_chrome_headless

    client_account(name: "Default Client")
    pm_account(name: "Default PM")
    VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
  end

  it "flips the card when the cvc control is used" do
    client = find_client_account
    pm = find_pm_account
    project = Project.create!(owner: client, participant: pm, status: :draft)

    visit edit_project_path(project)

    fill_in "Name", with: "Project Card"
    fill_in "Raw footage URL", with: "https://example.com/raw.mov"
    click_button "Add"

    click_button "Review and pay"

    expect(page).to have_css(".payment-card-shell", visible: :all)
    expect(page).to have_no_css(".payment-card-shell.is-flipped", visible: :all)

    click_button "Enter card security code"

    expect(page).to have_css(".payment-card-shell.is-flipped", visible: :all)
    expect(page).to have_field("CVC", with: "")

    find("#payment-card-number", visible: :all).click

    expect(page).to have_no_css(".payment-card-shell.is-flipped", visible: :all)
  end
end
