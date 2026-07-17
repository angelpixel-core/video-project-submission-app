require "rails_helper"

RSpec.describe WorkspaceResolver do
  around do |example|
    original_client = ENV["DEFAULT_CLIENT_EMAIL"]
    original_pm = ENV["DEFAULT_PM_EMAIL"]

    example.run

    restore_env("DEFAULT_CLIENT_EMAIL", original_client)
    restore_env("DEFAULT_PM_EMAIL", original_pm)
  end

  def restore_env(key, value)
    if value.nil?
      ENV.delete(key)
    else
      ENV[key] = value
    end
  end

  it "resolves the workspace client and pm from env vars" do
    ENV["DEFAULT_CLIENT_EMAIL"] = "client@example.com"
    ENV["DEFAULT_PM_EMAIL"] = "pm@example.com"

    client = Client.create!(name: "Client", email: "client@example.com")
    pm = Pm.create!(name: "PM", email: "pm@example.com")

    expect(described_class.new.client).to eq(client)
    expect(described_class.new.pm).to eq(pm)
  end

  it "fails explicitly when the client env var is missing" do
    ENV.delete("DEFAULT_CLIENT_EMAIL")
    ENV["DEFAULT_PM_EMAIL"] = "pm@example.com"

    expect { described_class.new.client }.to raise_error(KeyError, /DEFAULT_CLIENT_EMAIL/)
  end

  it "fails explicitly when the pm env var is missing" do
    ENV["DEFAULT_CLIENT_EMAIL"] = "client@example.com"
    ENV.delete("DEFAULT_PM_EMAIL")

    expect { described_class.new.pm }.to raise_error(KeyError, /DEFAULT_PM_EMAIL/)
  end
end
