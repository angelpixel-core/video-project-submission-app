module Identity
  module Application
    module Queries
      class ResolveWorkspaceAccounts
        def self.call(client_email:, pm_email:)
          new(client_email:, pm_email:).call
        end

        def initialize(client_email:, pm_email:)
          @client_email = client_email
          @pm_email = pm_email
        end

        def call
          Core::Result::Success.(
            data: {
              client: Identity::Domain::Repositories::AccountRepository.find_by_email_and_role(client_email, :client),
              pm: Identity::Domain::Repositories::AccountRepository.find_by_email_and_role(pm_email, :pm)
            }
          )
        end

        private

        attr_reader :client_email, :pm_email
      end
    end
  end
end
