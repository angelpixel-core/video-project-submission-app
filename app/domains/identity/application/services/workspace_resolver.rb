module Identity
  module Application
    module Services
      class WorkspaceResolver
        def initialize(
          query: Identity::Application::Queries::ResolveWorkspaceAccounts,
          account_repository: Identity::Adapters::Persistence::Account::Repository.new,
          user_repository: Identity::Domain::Repositories::UserRepository
        )
          @query = query
          @account_repository = account_repository
          @user_repository = user_repository
        end

        def workspace_for(role)
          resolve_accounts.fetch(role.to_sym)
        end

        private

        attr_reader :query, :account_repository, :user_repository

        def resolve_accounts
          @resolve_accounts ||= query.call(
            client_email: fetch_required_email("DEFAULT_CLIENT_EMAIL"),
            pm_email: fetch_required_email("DEFAULT_PM_EMAIL"),
            user_repository: user_repository,
            account_repository: account_repository
          ).data
        end

        def fetch_required_email(key)
          value = ENV[key].to_s.strip
          return value if value.present?

          raise KeyError, "Missing required environment variable: #{key}"
        end
      end
    end
  end
end
