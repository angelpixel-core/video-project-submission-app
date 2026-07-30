module Billing
  module Domain
    module Aggregates
      class Invoice
        attr_reader :number, :order_id, :order_name, :recipient_name, :recipient_email, :lines, :content, :content_type, :issued_at

        def initialize(number:, order_id:, order_name:, recipient_name:, recipient_email:, lines:, content:, content_type: "text/html", issued_at: Time.current)
          @number = number.to_s.strip
          @order_id = order_id.to_i
          @order_name = order_name.to_s.strip
          @recipient_name = recipient_name.to_s.strip
          @recipient_email = recipient_email.to_s.strip
          @lines = Array(lines).map do |line|
            line.respond_to?(:to_h) ? line : Billing::Domain::Entities::InvoiceLine.new(**line)
          end
          @content = content.to_s
          @content_type = content_type.to_s.strip.presence || "text/html"
          @issued_at = issued_at
        end

        def filename(extension = nil)
          "#{number}.#{extension.presence || default_extension}"
        end

        def total_cents
          lines.sum(&:line_total_cents)
        end

        def html?
          content_type == "text/html"
        end

        def to_h
          {
            number: number,
            order_id: order_id,
            order_name: order_name,
            recipient_name: recipient_name,
            recipient_email: recipient_email,
            lines: lines.map(&:to_h),
            content: content,
            content_type: content_type,
            issued_at: issued_at
          }
        end

        private

        def default_extension
          html? ? "html" : "pdf"
        end
      end
    end
  end
end
