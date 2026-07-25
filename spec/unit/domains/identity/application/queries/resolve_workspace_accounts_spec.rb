require "rails_helper"

require Rails.root.join("app/domains/identity/application/queries/resolve_workspace_accounts")

RSpec.describe Identity::Application::Queries::ResolveWorkspaceAccounts do
  it "resolves accounts through user memberships and falls back to legacy account lookup" do
    client_workspace = build_client_account(email: "client@example.com", name: "Client")
    pm_workspace = build_pm_account(email: "pm@example.com", name: "PM")

    user_repository = class_double(Identity::Domain::Repositories::UserRepository).as_stubbed_const
    account_repository = instance_double(Identity::Adapters::Persistence::Account::Repository)

    client_user = Identity::Domain::Aggregates::User.create!(name: "Client User", email: "client@example.com", access_state: :active)
    pm_user = Identity::Domain::Aggregates::User.create!(name: "PM User", email: "pm@example.com", access_state: :active)

    allow(user_repository).to receive(:find_by_email).with("client@example.com").and_return(client_user)
    allow(user_repository).to receive(:find_by_email).with("pm@example.com").and_return(pm_user)

    allow(account_repository).to receive(:find_by_user_and_role).with(client_user, :client).and_return([client_workspace])
    allow(account_repository).to receive(:find_by_user_and_role).with(pm_user, :pm).and_return([pm_workspace])

    result = described_class.call(
      client_email: "client@example.com",
      pm_email: "pm@example.com",
      user_repository: user_repository,
      account_repository: account_repository
    )

    expect(result.data[:client]).to eq(client_workspace)
    expect(result.data[:pm]).to eq(pm_workspace)
  end

  it "falls back to direct account lookup when user resolution is unavailable" do
    user_repository = class_double(Identity::Domain::Repositories::UserRepository).as_stubbed_const
    account_repository = instance_double(Identity::Adapters::Persistence::Account::Repository)

    allow(user_repository).to receive(:find_by_email).and_return(nil)
    fallback_client = build_client_account(email: "fallback-client@example.com", name: "Fallback Client")
    fallback_pm = build_pm_account(email: "fallback-pm@example.com", name: "Fallback PM")

    allow(account_repository).to receive(:find_by_email_and_role).with("client@example.com", :client).and_return(fallback_client)
    allow(account_repository).to receive(:find_by_email_and_role).with("pm@example.com", :pm).and_return(fallback_pm)

    result = described_class.call(
      client_email: "client@example.com",
      pm_email: "pm@example.com",
      user_repository: user_repository,
      account_repository: account_repository
    )

    expect(result.data[:client]).to eq(fallback_client)
    expect(result.data[:pm]).to eq(fallback_pm)
  end

  def build_client_account(email: "client@example.com", name: "Client")
    Identity::Domain::Aggregates::Account.create!(name: name, email: email, role: :client)
  end

  def build_pm_account(email: "pm@example.com", name: "PM")
    Identity::Domain::Aggregates::Account.create!(name: name, email: email, role: :pm)
  end
end
