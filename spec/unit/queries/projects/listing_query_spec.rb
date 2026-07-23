require "rails_helper"
require Rails.root.join("app/queries/projects/listing_query")

RSpec.describe Projects::ListingQuery do
  include ActiveSupport::Testing::TimeHelpers

  before do
    Client.create!(name: "Default Client", email: "client@example.com")
    PM.create!(name: "Default PM", email: "pm@example.com")
    VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    VideoType.create!(name: "Social Cut", description: "Social edit", price_cents: 15_000, output_format: "mp4")
  end

  it "orders by newest first by default" do
    client = Client.find_by!(email: "client@example.com")
    pm = PM.find_by!(email: "pm@example.com")

    travel_to 2.days.ago do
      Project.create!(client: client, pm: pm, name: "Older Project", raw_footage_url: "https://example.com/older.mov", status: :pending)
    end

    travel_to 1.day.ago do
      Project.create!(client: client, pm: pm, name: "Newer Project", raw_footage_url: "https://example.com/newer.mov", status: :in_progress)
    end

    names = described_class.new(ActionController::Parameters.new({})).call.map(&:name)

    expect(names).to eq([ "Newer Project", "Older Project" ])
  ensure
    travel_back
  end

  it "orders created_at ascending when requested" do
    client = Client.find_by!(email: "client@example.com")
    pm = PM.find_by!(email: "pm@example.com")

    travel_to 2.days.ago do
      Project.create!(client: client, pm: pm, name: "Older Project", raw_footage_url: "https://example.com/older.mov", status: :pending)
    end

    travel_to 1.day.ago do
      Project.create!(client: client, pm: pm, name: "Newer Project", raw_footage_url: "https://example.com/newer.mov", status: :in_progress)
    end

    names = described_class.new(ActionController::Parameters.new(sort: "created_at", direction: "asc")).call.map(&:name)

    expect(names).to eq([ "Older Project", "Newer Project" ])
  ensure
    travel_back
  end

  it "orders by total budget when requested" do
    client = Client.find_by!(email: "client@example.com")
    pm = PM.find_by!(email: "pm@example.com")
    highlight_reel = VideoType.find_by!(name: "Highlight Reel")
    social_cut = VideoType.find_by!(name: "Social Cut")

    low_budget = Project.create!(client: client, pm: pm, name: "Low Budget", raw_footage_url: "https://example.com/low.mov", status: :pending)
    low_budget.video_type_selections.create!(video_type: social_cut, quantity: 1)

    high_budget = Project.create!(client: client, pm: pm, name: "High Budget", raw_footage_url: "https://example.com/high.mov", status: :pending)
    high_budget.video_type_selections.create!(video_type: highlight_reel, quantity: 3)

    names = described_class.new(ActionController::Parameters.new(sort: "total_budget")).call.map(&:name)

    expect(names).to eq([ "High Budget", "Low Budget" ])
  end

  it "paginates ten records per page by default" do
    client = Client.find_by!(email: "client@example.com")
    pm = PM.find_by!(email: "pm@example.com")

    11.times do |index|
      Project.create!(client: client, pm: pm, name: "Project #{index + 1}", raw_footage_url: "https://example.com/#{index + 1}.mov", status: :pending)
    end

    first_page = described_class.new(ActionController::Parameters.new(page: 1)).call
    second_page = described_class.new(ActionController::Parameters.new(page: 2)).call

    expect(first_page.to_a.size).to eq(10)
    expect(second_page.to_a.size).to eq(1)
  end

  it "whitelists sorting params and normalizes the page" do
    query = described_class.new(ActionController::Parameters.new(sort: "name", direction: "sideways", page: "0"))

    expect(query.sort).to be_nil
    expect(query.direction).to be_nil
    expect(query.page).to eq(1)
  end
end
