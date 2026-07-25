module Identity
  module Application
    module Queries
      class ResolveWorkspaceAccounts
        def initialize(
          client_email:,
          pm_email:,
          user_repository: Identity::Domain::Repositories::UserRepository,
          account_repository: Identity::Adapters::Persistence::Account::Repository.new
        )
          @client_email = client_email
          @pm_email = pm_email
          @user_repository = user_repository
          @account_repository = account_repository
        end

        def self.call(
          client_email:,
          pm_email:,
          user_repository: Identity::Domain::Repositories::UserRepository,
          account_repository: Identity::Adapters::Persistence::Account::Repository.new
        )
          new(client_email:, pm_email:, user_repository:, account_repository:).call
        end

        def call
          Core::Result::Success.(
            data: {
              client: resolve_account(client_email, :client),
              pm: resolve_account(pm_email, :pm)
            }
          )
        end

        private

        attr_reader :client_email, :pm_email, :user_repository, :account_repository

        def resolve_account(email, role)
          user = user_repository.find_by_email(email)
          return unless user.present?

          account = account_repository.find_by_user_and_role(user, role)
          return account.first if account.respond_to?(:first)

          account
        end
      end
    end
  end
end
