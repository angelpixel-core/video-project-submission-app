module Payments
  module Result
    class Success < Base
      def self.call(data:)
        new(data: data)
      end

      def success?
        true
      end

      def failure?
        false
      end
    end
  end
end
