module Workspace
  module Context
    class Provider
      def client
        resolve_accounts.fetch(:client)
      end

      def pm
        resolve_accounts.fetch(:pm)
      end

      private

      def resolve_accounts
        @resolve_accounts ||= Identity::Application::Queries::ResolveWorkspaceAccounts.call(
          client_email: fetch_required_email("DEFAULT_CLIENT_EMAIL"),
          pm_email: fetch_required_email("DEFAULT_PM_EMAIL")
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
