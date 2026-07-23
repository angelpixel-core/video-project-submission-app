module Capacity
  module Application
    module Queries
      class CheckCapacity
        def self.call(offer:, quantity: 1)
          available_units = Capacity::Domain::Policies::CapacityCalculationPolicy.available_units_for(offer)
          available = quantity.to_i <= available_units

          Core::Result::Success.(data: { available: available, available_units: available_units })
        end
      end
    end
  end
end
