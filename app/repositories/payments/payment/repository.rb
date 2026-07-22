module Payments
  module Payment
    class Repository
      def self.find_by_id(id)
        ::Payment.find_by(id: id)
      end

      def self.find_by_provider_reference(provider_reference)
        ::Payment.find_by(provider_reference: provider_reference)
      end
    end
  end
end
