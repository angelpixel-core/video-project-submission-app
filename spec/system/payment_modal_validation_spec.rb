require "rails_helper"

RSpec.describe "Payment modal validation", type: :system, js: true do
  before do
    driven_by :selenium_chrome_headless

    Client.create!(name: "Default Client", email: "client@example.com")
    PM.create!(name: "Default PM", email: "pm@example.com")
    VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
  end

  it "formats and validates card fields" do
    client = Client.find_by!(email: "client@example.com")
    pm = PM.find_by!(email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, status: :draft)

    visit edit_project_path(project)

    fill_in "Name", with: "Project Card"
    fill_in "Raw footage URL", with: "https://example.com/raw.mov"
    click_button "Add"
    click_button "Review and pay"

    find("#payment-name", visible: :all).set("Jane Doe")
    find("#payment-card-number", visible: :all).set("4242424242424242")
    find("#payment-card-expiry", visible: :all).set(Date.current.next_month.strftime("%m/%y"))
    click_button "Enter card security code"
    find("#payment-card-cvc", visible: :all).set("123")

    expect(page).to have_field("Card number", with: "4242 4242 4242 4242")
    expect(page).to have_field("Expiry", with: Date.current.next_month.strftime("%m/%y"))
    expect(page).to have_css("#payment-card-number.is-valid", visible: :all)
    expect(page).to have_css("#payment-card-expiry.is-valid", visible: :all)
    expect(page).to have_css("#payment-card-cvc.is-valid", visible: :all)
    expect(page).to have_css("button[data-order-form-target='finalizeButton']:not(:disabled)", visible: :all)
  end

  it "flags an expired card" do
    client = Client.find_by!(email: "client@example.com")
    pm = PM.find_by!(email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, status: :draft)

    visit edit_project_path(project)

    fill_in "Name", with: "Project Card"
    fill_in "Raw footage URL", with: "https://example.com/raw.mov"
    click_button "Add"
    click_button "Review and pay"

    find("#payment-name", visible: :all).set("Jane Doe")
    find("#payment-card-number", visible: :all).set("4242424242424242")
    find("#payment-card-expiry", visible: :all).set(Date.current.prev_month.strftime("%m/%y"))
    click_button "Enter card security code"
    find("#payment-card-cvc", visible: :all).set("123")

    expect(page).to have_css("#payment-card-expiry.is-invalid", visible: :all)
    expect(page).to have_css("#payment-card-error", text: "Card has expired.")
    expect(page).to have_css("button[data-order-form-target='finalizeButton']:disabled", visible: :all)
  end
end
