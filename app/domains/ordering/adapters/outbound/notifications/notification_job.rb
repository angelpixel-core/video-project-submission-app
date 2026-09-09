module Ordering
  module Adapters
    module Outbound
      module Notifications
        class NotificationJob < Ordering::Application::Ports::NotificationPort
          def self.call(order:)
            # TODO(cleanup): Replace with the Notifications boundary contract.
            ::NotificationJob.perform_later(order.id)
          end
        end
      end
    end
  end
end
