require "dry/system/container"

require_relative "../domains/payments/application/ports/payment_gateway"
require_relative "../domains/payments/adapters/outbound/gateways/fake"
require_relative "../domains/payments/adapters/outbound/gateways/stripe_payment_gateway"
require_relative "../domains/payments/adapters/outbound/gateways/mercadopago_payment_gateway"

class AppContainer < Dry::System::Container
  configure do |config|
    config.root = Rails.root
  end

  register("payments.gateways.fake", Payments::Adapters::Outbound::Gateways::Fake)
  register("payments.gateways.stripe", Payments::Adapters::Outbound::Gateways::StripePaymentGateway)
  register("payments.gateways.mercadopago", Payments::Adapters::Outbound::Gateways::MercadoPagoPaymentGateway)
end
