module Payments
  module Notifications
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
          Payments::Notifications::LoggerChannel.new(intent),
          Payments::Notifications::EmailChannel.new(intent)
        ]
      end
    end
  end
end
