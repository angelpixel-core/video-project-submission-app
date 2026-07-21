require "rails_helper"

RSpec.describe "Payment modal card flip", type: :system, js: true do
  before do
    driven_by :selenium_chrome_headless

    Client.create!(name: "Default Client", email: "client@example.com")
    PM.create!(name: "Default PM", email: "pm@example.com")
    VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
  end

  it "flips the card when the cvc field gains focus" do
    client = Client.find_by!(email: "client@example.com")
    pm = PM.find_by!(email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, status: :draft)

    visit edit_project_path(project)

    fill_in "Name", with: "Project Card"
    fill_in "Raw footage URL", with: "https://example.com/raw.mov"
    click_button "Add"

    click_button "Review and pay"

    expect(page).to have_css(".payment-card-shell", visible: :all)
    expect(page).to have_no_css(".payment-card-shell.is-flipped", visible: :all)

    find("#payment-card-cvc").click

    expect(page).to have_css(".payment-card-shell.is-flipped", visible: :all)

    find("#payment-card-number").click

    expect(page).to have_no_css(".payment-card-shell.is-flipped", visible: :all)
  end
end
