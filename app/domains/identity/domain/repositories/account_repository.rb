module Identity
  module Domain
    module Repositories
      class AccountRepository
        def self.find_by_email(email)
          Identity::Domain::Aggregates::Account.find_by(email: email.to_s.strip.downcase)
        end

        def self.find_by_email_and_role(email, role)
          normalized_role = role.to_s.strip.downcase
          scope = normalized_role == "pm" ? PM : Client

          scope.find_by(email: email.to_s.strip.downcase)
        end

        def self.find_by_role(role)
          role.to_s.strip.downcase == "pm" ? PM.all : Client.all
        end
      end
    end
  end
end
