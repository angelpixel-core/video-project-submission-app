module PaymentNotifications
  class LoggerChannel
    def initialize(intent)
      @intent = intent
    end

    def call
      Rails.logger.info("Payment notification #{intent.event_type} for payment #{intent.payment_id} (#{intent.from_status} -> #{intent.to_status})")
    end

    private

    attr_reader :intent
  end
end
