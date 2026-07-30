require "rails_helper"

RSpec.describe Offering do
  it "inherits from the catalog offering aggregate" do
    expect(described_class.superclass).to eq(Catalog::Domain::Aggregates::Offering)
  end
end
