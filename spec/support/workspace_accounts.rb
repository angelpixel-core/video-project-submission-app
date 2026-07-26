module WorkspaceAccounts
  def workspace_account(role, email:, name:)
    account = Identity::Domain::Aggregates::Account.find_by(email: email)
    unless account
      account = Identity::Domain::Aggregates::Account.create!(name: name, email: email, role: role)
    end
    account.update_columns(name: name) if account.name != name

    user = Identity::Domain::Aggregates::User.find_by(email: email)
    unless user
      user = Identity::Domain::Aggregates::User.create!(name: name, email: email, access_state: :active, notification_settings: {})
    end
    user.update_columns(name: name, access_state: "active", notification_settings: {}) if user.name != name || user.access_state != "active" || user.notification_settings.blank?

    Identity::Domain::Aggregates::Membership.find_or_create_by!(user: user, account: account) do |membership|
      membership.role = role
    end

    account
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
