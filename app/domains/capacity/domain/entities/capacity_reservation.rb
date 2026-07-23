module Capacity
  module Domain
    module Entities
      class CapacityReservation
        attr_reader :capacity, :units, :status

        def initialize(capacity:, units:, status: :reserved)
          @capacity = capacity
          @units = units.to_i
          @status = status.to_sym
        end
      end
    end
  end
end
