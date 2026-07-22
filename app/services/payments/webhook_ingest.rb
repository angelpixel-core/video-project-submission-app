module Payments
  class WebhookIngest
    WEBHOOK_SECRET = Payments::Webhook::Event::Ingest::WEBHOOK_SECRET
    SUPPORTED_PROVIDERS = Payments::Webhook::Event::Ingest::SUPPORTED_PROVIDERS

    def self.call(provider:, raw_body:, headers:)
      Payments::Webhook::Event::Ingest.call(provider:, raw_body:, headers:)
    end
  end
end
