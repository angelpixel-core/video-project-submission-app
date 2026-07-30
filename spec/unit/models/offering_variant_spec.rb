require "rails_helper"

RSpec.describe OfferingVariant do
  it "inherits from the catalog offering variant entity" do
    expect(described_class.superclass).to eq(Catalog::Domain::Entities::OfferingVariant)
  end
end
