module PaymentNotifications
  class Dispatcher
    def self.call(intent:)
      new(intent:).call
    end

    def initialize(intent:)
      @intent = intent
    end

    def call
      delivery_channels.each(&:call)
    end

    private

    attr_reader :intent

    def delivery_channels
      [
        PaymentNotifications::LoggerChannel.new(intent)
      ]
    end
  end
end
