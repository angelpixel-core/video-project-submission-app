module Identity
  module Domain
    module Repositories
      class UserRepository
        def self.find_by_email(email)
          Identity::Adapters::Persistence::User::UserRecord.find_by(email: normalize_email(email))
        end

        def self.find_by_role(role)
          Identity::Adapters::Persistence::User::UserRecord.joins(:memberships).where(memberships: { role: normalize_role(role) })
        end

        def self.find_by_email_and_role(email, role)
          Identity::Adapters::Persistence::User::UserRecord.joins(:memberships).find_by(
            email: normalize_email(email),
            memberships: { role: normalize_role(role) }
          )
        end

        def self.find_by_id(id)
          Identity::Adapters::Persistence::User::UserRecord.find_by(id: id)
        end

        def self.normalize_email(email)
          email.to_s.strip.downcase
        end

        def self.normalize_role(role)
          role.to_s.strip.downcase
        end
      end
    end
  end
end
