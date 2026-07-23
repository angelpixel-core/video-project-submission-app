module Identity
  module Domain
    module Aggregates
      class User < Account
        self.inheritance_column = :_type_disabled
      end
    end
  end
end
