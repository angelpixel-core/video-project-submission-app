module Catalog
  module Domain
    module Policies
      class AvailabilityPolicy
        def self.available?(offer, quantity: 1)
          Capacity::Domain::Policies::CapacityCalculationPolicy.available_units_for(offer) >= quantity.to_i
        end
      end
    end
  end
end
