module Ordering
  module Application
    module Ports
      class CapacityPort < Core::Services::Provider
        def reserve(order_id:, units:)
          raise NotImplementedError
        end

        def commit(reservation:)
          raise NotImplementedError
        end

        def release(reservation:)
          raise NotImplementedError
        end
      end
    end
  end
end
