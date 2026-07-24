module Identity
  module Application
    module Queries
      class ResolveWorkspaceAccounts
        def initialize(client_email:, pm_email:, account_repository: Identity::Adapters::Persistence::Account::Repository.new)
          @client_email = client_email
          @pm_email = pm_email
          @account_repository = account_repository
        end

        def self.call(client_email:, pm_email:)
          new(client_email:, pm_email:).call
        end

        def call
          Core::Result::Success.(
            data: {
              client: account_repository.find_by_email_and_role(client_email, :client),
              pm: account_repository.find_by_email_and_role(pm_email, :pm)
            }
          )
        end

        private

        attr_reader :client_email, :pm_email, :account_repository
      end
    end
  end
end
