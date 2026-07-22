module PaymentNotifications
  class EmailChannel
    def initialize(intent)
      @intent = intent
    end

    def call
      PaymentNotificationMailer.payment_status_changed(intent).deliver_now
    end

    private

    attr_reader :intent
  end
end
