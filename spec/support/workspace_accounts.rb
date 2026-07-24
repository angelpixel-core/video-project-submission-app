module WorkspaceAccounts
  def workspace_account(role, email:, name:)
    Identity::Domain::Aggregates::Account.create!(name: name, email: email, role: role)
  end

  def client_account(email: "client@example.com", name: "Client")
    workspace_account(:client, email: email, name: name)
  end

  def pm_account(email: "pm@example.com", name: "PM")
    workspace_account(:pm, email: email, name: name)
  end

  def find_client_account(email: "client@example.com")
    Identity::Domain::Aggregates::Account.find_by!(email: email, role: "client")
  end

  def find_pm_account(email: "pm@example.com")
    Identity::Domain::Aggregates::Account.find_by!(email: email, role: "pm")
  end
end

RSpec.configure do |config|
  config.include WorkspaceAccounts

  config.around(:each, type: :request) do |example|
    original_client = ENV["DEFAULT_CLIENT_EMAIL"]
    original_pm = ENV["DEFAULT_PM_EMAIL"]

    ENV["DEFAULT_CLIENT_EMAIL"] = "client@example.com" if original_client.blank?
    ENV["DEFAULT_PM_EMAIL"] = "pm@example.com" if original_pm.blank?

    example.run

    restore_workspace_env("DEFAULT_CLIENT_EMAIL", original_client)
    restore_workspace_env("DEFAULT_PM_EMAIL", original_pm)
  end

  config.around(:each, type: :system) do |example|
    original_client = ENV["DEFAULT_CLIENT_EMAIL"]
    original_pm = ENV["DEFAULT_PM_EMAIL"]

    ENV["DEFAULT_CLIENT_EMAIL"] = "client@example.com" if original_client.blank?
    ENV["DEFAULT_PM_EMAIL"] = "pm@example.com" if original_pm.blank?

    example.run

    restore_workspace_env("DEFAULT_CLIENT_EMAIL", original_client)
    restore_workspace_env("DEFAULT_PM_EMAIL", original_pm)
  end
end

def restore_workspace_env(key, value)
  if value.nil?
    ENV.delete(key)
  else
    ENV[key] = value
  end
end
