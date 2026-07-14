require "rails_helper"

RSpec.describe "DB health check" do
  it "returns OK on /up/db" do
    get "/up/db"

    expect(response).to have_http_status(:ok)
    expect(response.body).to eq("ok")
  end
end
