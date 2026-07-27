module Ordering
  module Domain
    module Policies
      class OrderCancellationPolicy
        def self.allowed?(order)
          !order.completed? && !order.cancelled?
        end
      end
    end
  end
end
