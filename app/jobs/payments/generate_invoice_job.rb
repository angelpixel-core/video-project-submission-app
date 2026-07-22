module Payments
  class GenerateInvoiceJob < ApplicationJob
    retry_on ActiveRecord::Deadlocked, wait: 1.second, attempts: 5

    def perform(payment_id)
      payment = ::Payment.find_by(id: payment_id)
      return unless payment.present?
      return unless payment.succeeded?
      return if payment.payment_invoice_delivery_intents.exists?

      invoice = Payments::InvoiceBuilder.call(payment: payment)

      payment.with_lock do
        return if payment.payment_invoice_delivery_intents.exists?

        payment.invoice_number ||= invoice.number
        payment.invoice_document.attach(
          io: StringIO.new(invoice.content),
          filename: invoice.filename,
          content_type: invoice.content_type
        )
        payment.update!(invoice_number: invoice.number, invoice_generated_at: Time.current)

        PaymentInvoiceDeliveryIntent.create!(payment: payment, status: :pending, scheduled_at: Time.current)
      end
    end
  end
end
