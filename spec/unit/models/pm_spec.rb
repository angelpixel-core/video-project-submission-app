require "rails_helper"

RSpec.describe PM do
  it "inherits from the shared account aggregate" do
    expect(described_class.superclass).to eq(Identity::Domain::Aggregates::Account)
  end

  it "normalizes and validates email addresses" do
    pm = described_class.new(name: "PM", email: "  PM@example.com  ")

    expect(pm).to be_valid
    expect(pm.email).to eq("pm@example.com")
  end
end
