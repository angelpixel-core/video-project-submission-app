require "rails_helper"
require Rails.root.join("app/services/pm_projects_table_params")

RSpec.describe PMProjectsTableParams do
  it "defaults to created_at and page 1" do
    params = described_class.new(ActionController::Parameters.new({}))

    expect(params.sort).to be_nil
    expect(params.direction).to be_nil
    expect(params.page).to eq(1)
  end

  it "whitelists sort, direction and normalizes page" do
    params = described_class.new(ActionController::Parameters.new(sort: "total_budget", direction: "asc", page: "3"))

    expect(params.sort).to eq("total_budget")
    expect(params.direction).to eq("asc")
    expect(params.page).to eq(3)
  end

  it "falls back to created_at for invalid sort and page" do
    params = described_class.new(ActionController::Parameters.new(sort: "name", direction: "sideways", page: "0"))

    expect(params.sort).to be_nil
    expect(params.direction).to be_nil
    expect(params.page).to eq(1)
  end
end
