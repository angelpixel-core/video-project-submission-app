module Capacity
  module Domain
    module Policies
      class CapacityCalculationPolicy
        DEFAULT_TOTAL_UNITS = 100

        def self.available_units_for(_offer)
          total_units = ENV.fetch("CAPACITY_TOTAL_UNITS", DEFAULT_TOTAL_UNITS).to_i
          reserved_units = Ordering::Adapters::Persistence::Order::OrderRecord
            .where(status: %w[placed confirmed])
            .joins(:order_line_records)
            .sum("order_lines.quantity")
          [ total_units - reserved_units, 0 ].max
        end
      end
    end
  end
end
