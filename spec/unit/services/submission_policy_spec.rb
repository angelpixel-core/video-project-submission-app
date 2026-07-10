require "rails_helper"

RSpec.describe SubmissionPolicy do
  it "allows a present submission" do
    expect(described_class.new(Object.new).allowed?).to be(true)
  end

  it "rejects a missing submission" do
    expect(described_class.new(nil).allowed?).to be(false)
  end
end
