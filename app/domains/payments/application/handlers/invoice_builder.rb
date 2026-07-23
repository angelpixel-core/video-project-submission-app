module Payments
  module Application
    module Handlers
      Invoice = Struct.new(:number, :filename, :content_type, :content, keyword_init: true)

      class InvoiceBuilder
        def self.call(payment:)
          new(payment:).call
        end

        def initialize(payment:)
          @payment = payment
        end

        def call
          Invoice.new(
            number: invoice_number,
            filename: "#{invoice_number}.html",
            content_type: "text/html",
            content: render_content
          )
        end

        private

        attr_reader :payment

        def invoice_number
          payment.invoice_number.presence || "INV-#{payment.id.to_s.rjust(6, '0')}"
        end

        def render_content
          <<~HTML
            <html>
              <body>
                <h1>Invoice #{invoice_number}</h1>
                <p>Project: #{payment.project.name}</p>
                <p>Client: #{payment.project.client.name}</p>
                <p>Payment ID: #{payment.id}</p>
                <p>Provider reference: #{payment.provider_reference}</p>
                <p>Amount: #{payment.currency} #{format('%.2f', payment.amount_cents.to_f / 100)}</p>
                <p>Paid at: #{payment.confirmed_at&.utc&.iso8601 || Time.current.utc.iso8601}</p>
              </body>
            </html>
          HTML
        end
      end
    end
  end
end
