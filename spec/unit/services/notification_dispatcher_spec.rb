require "rails_helper"

RSpec.describe NotificationDispatcher do
  it "returns the notification payload" do
    payload = { kind: "submission_created" }

    expect(described_class.new.deliver(payload)).to eq(payload)
  end
end
