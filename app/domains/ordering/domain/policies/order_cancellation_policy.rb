module Ordering
  module Domain
    module Policies
      class OrderCancellationPolicy
        def self.allowed?(order)
          order.pending? && !order.payment_paid? && !order.payment_flow_blocked?
        end
      end
    end
  end
end
