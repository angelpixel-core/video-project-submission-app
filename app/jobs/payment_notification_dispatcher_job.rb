class PaymentNotificationDispatcherJob < ApplicationJob
  retry_on ActiveRecord::Deadlocked, wait: 1.second, attempts: 5

  def perform(payment_notification_intent_id)
    intent = PaymentNotificationIntent.find_by(id: payment_notification_intent_id)
    return unless intent.present?
    return if intent.sent?

    PaymentNotifications::Dispatcher.call(intent: intent)
    intent.mark_sent!
  rescue StandardError => e
    intent.mark_failed!(e.message) if intent.present?
    raise
  end
end
