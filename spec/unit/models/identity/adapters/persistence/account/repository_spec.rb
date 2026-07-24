require "rails_helper"

RSpec.describe Identity::Adapters::Persistence::Account::Repository do
  describe "#find_by_email_and_role" do
    it "returns the role-specific account model" do
      client = client_account(name: "Client")
      pm = pm_account(name: "PM")

      expect(described_class.new.find_by_email_and_role("client@example.com", :client)).to eq(client.becomes(Identity::Domain::Aggregates::Account))
      expect(described_class.new.find_by_email_and_role("pm@example.com", :pm)).to eq(pm.becomes(Identity::Domain::Aggregates::Account))
    end
  end

  describe "#find_by_role" do
    it "returns the role scope" do
      client_account(name: "Client")
      pm_account(name: "PM")

      expect(described_class.new.find_by_role(:client)).to all(be_a(Identity::Domain::Aggregates::Account))
      expect(described_class.new.find_by_role(:pm)).to all(be_a(Identity::Domain::Aggregates::Account))
    end
  end
end
