module Ordering
  module Domain
    module Policies
      class OrderCompletionPolicy
        def self.allowed?(order)
          order.confirmed? && order.delivery_status.delivered?
        end
      end
    end
  end
end
