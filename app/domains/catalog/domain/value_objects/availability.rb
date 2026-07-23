module Catalog
  module Domain
    module ValueObjects
      class Availability
        attr_reader :available, :reason

        def initialize(available:, reason: nil)
          @available = !!available
          @reason = reason
        end

        def available?
          available
        end
      end
    end
  end
end
