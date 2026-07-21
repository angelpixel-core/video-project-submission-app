module Payments
  module PaymentProvider
    def self.call(*)
      raise NotImplementedError, "Use a concrete payment provider"
    end
  end
end
