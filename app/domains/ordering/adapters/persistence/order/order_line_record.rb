module Ordering
  module Adapters
    module Persistence
      module Order
        class OrderLineRecord < ApplicationRecord
          self.table_name = "order_lines"

          belongs_to :order_record, class_name: "Ordering::Adapters::Persistence::Order::OrderRecord", foreign_key: :order_id, inverse_of: :order_line_records

          def video_type
            @video_type ||= begin
              video_type_id = offering_snapshot.fetch("offering_id", nil)
              VideoType.find_by(id: video_type_id) || Struct.new(:name, :description, :price_cents, :output_format).new(
                offering_snapshot["name"],
                offering_snapshot["description"],
                offering_snapshot["price_cents"],
                offering_snapshot["output_format"]
              )
            end
          end
        end
      end
    end
  end
end
