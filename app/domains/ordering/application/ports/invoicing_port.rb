module Ordering
  module Application
    module Ports
      class InvoicingPort < Core::Services::Provider
        def self.call(...)
          raise NotImplementedError, "Use a concrete invoicing port"
        end
      end
    end
  end
end
