require "rails_helper"

RSpec.describe EmailAddress do
  it "strips surrounding whitespace" do
    expect(described_class.new("  user@example.com  ").to_s).to eq("user@example.com")
  end
end
