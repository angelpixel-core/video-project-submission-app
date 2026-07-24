require "rails_helper"

RSpec.describe Client do
  it "is an ActiveRecord model" do
    expect(described_class.superclass).to eq(Identity::Domain::Aggregates::Account)
  end

  it "normalizes and validates email addresses" do
    client = described_class.new(name: "Client", email: "  CLIENT@example.com  ")

    expect(client).to be_valid
    expect(client.email).to eq("client@example.com")
  end
end
