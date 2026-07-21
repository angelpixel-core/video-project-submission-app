namespace :payments do
  desc "Simulate a payment webhook delivery"
  task simulate_webhook: :environment do
    webhook_url = ENV["WEBHOOK_URL"]

    unless webhook_url.present?
      abort "WEBHOOK_URL is required"
    end

    result = Payments::WebhookSimulator.(
      webhook_url: webhook_url,
      provider: ENV.fetch("PROVIDER", "fake"),
      event_id: ENV.fetch("EVENT_ID", "evt_123"),
      type: ENV.fetch("TYPE", "payment.succeeded"),
      payment_id: ENV.fetch("PAYMENT_ID", "1"),
      provider_reference: ENV.fetch("PROVIDER_REFERENCE", "fake-abc123"),
      amount_cents: ENV.fetch("AMOUNT_CENTS", "50000")
    )

    if result.success?
      puts "Webhook delivered (#{result.data[:status_code]}): #{result.data[:body]}"
    else
      warn "Webhook delivery failed: #{result.message} (#{result.code})"
      warn result.data.inspect
      exit 1
    end
  end
end
