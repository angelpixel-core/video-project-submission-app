require "rails_helper"

RSpec.describe VideoType do
  it "inherits from the catalog video type entity" do
    expect(described_class.superclass).to eq(OfferingVariant)
  end

  it "requires the core attributes" do
    video_type = described_class.new

    expect(video_type).not_to be_valid
    expect(video_type.errors[:name]).to be_present
    expect(video_type.errors[:description]).to be_present
    expect(video_type.errors[:output_format]).to be_present
  end
end
