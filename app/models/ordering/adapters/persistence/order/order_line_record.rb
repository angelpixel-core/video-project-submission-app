module Ordering
  module Adapters
    module Persistence
      module Order
        class OrderLineRecord < ApplicationRecord
          self.table_name = "order_lines"

          belongs_to :order_record, class_name: "Ordering::Adapters::Persistence::Order::OrderRecord", foreign_key: :order_id, inverse_of: :order_line_records
        end
      end
    end
  end
end
