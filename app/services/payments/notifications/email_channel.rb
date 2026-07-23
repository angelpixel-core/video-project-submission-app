module Payments
  module Notifications
    class EmailChannel
      def initialize(intent)
        @intent = intent
      end

      def call
        PaymentNotificationMailer.payment_status_changed(intent, recipient_role: :client).deliver_now
        PaymentNotificationMailer.payment_status_changed(intent, recipient_role: :pm).deliver_now
      end

      private

      attr_reader :intent
    end
  end
end
