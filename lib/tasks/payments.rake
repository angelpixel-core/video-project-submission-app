namespace :payments do
  desc "Simulate a signed payment webhook delivery"
  task simulate_webhook: :environment do
    deliver_signed_webhook(default_type: "payment.succeeded")
  end

  desc "Send a signed fake payment webhook delivery"
  task send_signed_fake_webhook: :environment do
    deliver_signed_webhook(default_type: "payment.succeeded")
  end
end

def deliver_signed_webhook(default_type:)
  webhook_url = ENV["WEBHOOK_URL"].presence || "http://localhost:3000/payments/webhooks/fake/events"
  payment = resolved_payment_from_env

  result = Payments::WebhookSimulator.(
    webhook_url: webhook_url,
    provider: ENV["PROVIDER"].presence || "fake",
    event_id: ENV["EVENT_ID"].presence || "evt_123",
    type: ENV["TYPE"].presence || default_type,
    payment_id: payment&.id || ENV["PAYMENT_ID"].presence || "1",
    provider_reference: payment&.provider_reference.presence || ENV["PROVIDER_REFERENCE"].presence || "fake-abc123",
    amount_cents: payment&.amount_cents || ENV["AMOUNT_CENTS"].presence || "50000"
  )

  if result.success?
    puts "Webhook delivered (#{result.data[:status_code]}): #{result.data[:body]}"
  else
    warn "Webhook delivery failed: #{result.message} (#{result.code})"
    warn result.data.inspect
    exit 1
  end
end

def resolved_payment_from_env
  explicit_payment_id = ENV["PAYMENT_ID"].presence
  return Payment.find(explicit_payment_id) if explicit_payment_id.present?

  project_id = ENV["PROJECT_ID"].presence
  return unless project_id.present?

  project = Project.find(project_id)
  payment = project.active_payment || project.payments.order(created_at: :desc).first
  abort "Project #{project_id} has no payment" unless payment.present?

  payment
end
