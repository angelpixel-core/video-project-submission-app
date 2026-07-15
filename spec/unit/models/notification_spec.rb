require "rails_helper"

RSpec.describe Notification do
  it "is an ActiveRecord model" do
    expect(described_class.superclass).to eq(ApplicationRecord)
  end

  it "requires a project, pm, kind, and body" do
    notification = described_class.new

    expect(notification).not_to be_valid
    expect(notification.errors[:project]).to be_present
    expect(notification.errors[:pm]).to be_present
    expect(notification.errors[:kind]).to be_present
    expect(notification.errors[:body]).to be_present
  end
end
