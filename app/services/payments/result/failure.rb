module Payments
  module Result
    class Failure < Base
      def self.call(message:, code:, data: {})
        new(message: message, code: code, data: data)
      end

      def success?
        false
      end

      def failure?
        true
      end
    end
  end
end
