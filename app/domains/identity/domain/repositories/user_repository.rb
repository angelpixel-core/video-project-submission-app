module Identity
  module Domain
    module Repositories
      class UserRepository
        def self.find_by_email(email)
          AccountRepository.find_by_email(email)
        end

        def self.find_by_role(role)
          AccountRepository.find_by_role(role)
        end
      end
    end
  end
end
