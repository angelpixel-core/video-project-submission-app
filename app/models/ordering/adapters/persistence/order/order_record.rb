module Ordering
  module Adapters
    module Persistence
      module Order
        class OrderRecord < ApplicationRecord
          self.table_name = "orders"

          has_many :order_line_records, class_name: "Ordering::Adapters::Persistence::Order::OrderLineRecord", foreign_key: :order_id, dependent: :destroy, inverse_of: :order_record
          has_one :source_video_record, class_name: "Ordering::Adapters::Persistence::Order::SourceVideoRecord", foreign_key: :order_id, dependent: :destroy, inverse_of: :order_record
        end
      end
    end
  end
end
