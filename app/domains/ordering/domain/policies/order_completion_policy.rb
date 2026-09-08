module Ordering
  module Domain
    module Policies
      class OrderCompletionPolicy
        def self.allowed?(order)
          order.confirmed? && order.production_status.completed? && order.delivered? && !order.payment_flow_blocked?
        end
      end
    end
  end
end
