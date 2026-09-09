module Ordering
  module Adapters
    module Outbound
      module Capacity
        class Commands < Ordering::Application::Ports::CapacityPort
          def reserve(order_id:, units:)
            ::Capacity::Application::Commands::ReserveCapacity.call(order_id:, units:)
          end

          def commit(reservation:)
            ::Capacity::Application::Commands::CommitCapacity.call(order_id: reservation.order_id)
          end

          def release(reservation:)
            ::Capacity::Application::Commands::ReleaseCapacity.call(order_id: reservation.order_id)
          end
        end
      end
    end
  end
end
