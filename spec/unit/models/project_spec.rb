require "rails_helper"

RSpec.describe Project do
  it "is an ActiveRecord model" do
    expect(described_class.superclass).to eq(ApplicationRecord)
  end
end
