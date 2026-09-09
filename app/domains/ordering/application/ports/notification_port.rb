module Ordering
  module Application
    module Ports
      class NotificationPort < Core::Services::Provider
        def self.call(...)
          raise NotImplementedError, "Use a concrete notification port"
        end
      end
    end
  end
end
