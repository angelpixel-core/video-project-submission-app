require "rails_helper"

RSpec.describe Comment do
  it "requires a project, an author, and a body" do
    comment = described_class.new

    expect(comment).not_to be_valid
    expect(comment.errors[:project]).to be_present
    expect(comment.errors[:author]).to be_present
    expect(comment.errors[:body]).to be_present
  end
end
