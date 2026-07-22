module Payments
  class PaymentEventHandler
    DEMO_FAILURE_MESSAGE = "Demo transient webhook failure.".freeze

    HANDLED_EVENT_TYPES = {
      "payment.succeeded" => :handle_payment_succeeded,
      "payment.failed" => :handle_payment_failed
    }.freeze

    def self.call(event:)
      new(event:).call
    end

    def initialize(event:)
      @event = event
    end

    def call
      attempt = nil

      event.with_lock do
        attempt = event.record_processing_attempt!
      end

      maybe_fail_demo_once!(attempt)

      event.with_lock do
        return already_processed_result(attempt:) if event.processed_at.present?

        handler = HANDLED_EVENT_TYPES[event.event_type]
        return fail_event("Unsupported payment webhook event type.", :unknown_event_type, attempt:) unless handler

        payment = locate_payment
        return fail_event("Unable to locate payment for webhook event.", :payment_not_found, attempt:) unless payment

        event.synchronize_payment_context!(payment)

        send(handler, payment, attempt: attempt)
      end
    rescue Payments::DemoTransientFailure => e
      record_demo_failure!(e.message, attempt: attempt)
      raise
    end

    private

    attr_reader :event

    def already_processed_result(attempt:)
      event.mark_processed!(attempt: attempt)
      Payments::Result::Success.(data: { event: event, payment: associated_payment, applied: false, reason: :already_processed })
    end

    def handle_payment_succeeded(payment, attempt:)
      return finish_noop(payment, :stale_payment_state, attempt: attempt) if terminal_payment_status?(payment)

      payment.update!(
        status: :succeeded,
        confirmed_at: Time.current,
        failed_at: nil,
        provider_reference: payment.provider_reference.presence || event_payload_provider_reference
      )

      update_payment_attempt!(payment, status: :succeeded)
      event.mark_processed!(attempt: attempt)

      Payments::Result::Success.(data: { event: event, payment: payment, applied: true })
    rescue ActiveRecord::RecordInvalid => e
      fail_event(e.message, :payment_update_failed)
    end

    def handle_payment_failed(payment, attempt:)
      return finish_noop(payment, :stale_payment_state, attempt: attempt) if terminal_payment_status?(payment)

      payment.update!(
        status: :failed,
        failed_at: Time.current,
        confirmed_at: nil,
        provider_reference: payment.provider_reference.presence || event_payload_provider_reference
      )

      update_payment_attempt!(payment, status: :failed, error_message: "Payment failed via webhook.")
      event.mark_processed!(attempt: attempt)

      Payments::Result::Success.(data: { event: event, payment: payment, applied: true })
    rescue ActiveRecord::RecordInvalid => e
      fail_event(e.message, :payment_update_failed)
    end

    def finish_noop(payment, reason, attempt: nil)
      event.mark_processed!(attempt: attempt)
      Payments::Result::Success.(data: { event: event, payment: payment, applied: false, reason: reason })
    end

    def locate_payment
      payment = payment_by_id
      return payment if payment.present?

      payment_by_provider_reference
    end

    def payment_by_id
      payment_id = event_payload["data"].to_h["payment_id"].presence
      return if payment_id.blank?

      Payment.find_by(id: payment_id)
    end

    def payment_by_provider_reference
      reference = event_payload["data"].to_h["provider_reference"].presence || event_payload["provider_reference"].presence
      return if reference.blank?

      Payment.find_by(provider_reference: reference)
    end

    def associated_payment
      locate_payment
    end

    def update_payment_attempt!(payment, status:, error_message: nil)
      attempt = payment.payment_attempts.order(created_at: :desc).first
      return unless attempt.present?

      attempt.update!(
        status: status,
        error_message: error_message.presence || attempt.error_message,
        response_payload: attempt.response_payload.to_h.merge("webhook_event_id" => event.provider_event_id, "webhook_event_type" => event.event_type)
      )
    end

    def mark_event_processed!
      event.mark_processed!
    end

    def fail_event(message, code, attempt: nil)
      event.mark_failed!(message, attempt: attempt) if event.persisted?
      Payments::Result::Failure.(message: message, code: code, data: { event: event })
    end

    def maybe_fail_demo_once!(attempt)
      return unless demo_fail_once?
      return unless attempt.present? && attempt.attempt_number == 1

      raise Payments::DemoTransientFailure, DEMO_FAILURE_MESSAGE
    end

    def demo_fail_once?
      ActiveModel::Type::Boolean.new.cast(event_payload["data"].to_h["demo_fail_once"])
    end

    def record_demo_failure!(message, attempt: nil)
      event.mark_failed!(message, attempt: attempt)
    end

    def event_payload
      @event_payload ||= event.payload.to_h
    end

    def event_payload_provider_reference
      event_payload["data"].to_h["provider_reference"].presence || event_payload["provider_reference"].presence
    end

    def terminal_payment_status?(payment)
      Payment::TERMINAL_STATUSES.include?(payment.status)
    end
  end
end
