module Ordering
  module Domain
    module Policies
      class OrderPlacementPolicy
        def self.allowed?(order)
          order.draft? && order.customer_snapshot.present? && order.order_lines.any?
        end
      end
    end
  end
end
