module Ordering
  module Application
    module Commands
      class ProcessSubmission
        def self.call(submission:, payment_command: Payments::Application::Commands::CreatePayment, payment_gateway: nil)
          new(submission:, payment_command:, payment_gateway:).call
        end

        def initialize(submission:, payment_command:, payment_gateway: nil)
          @submission = submission
          @payment_command = payment_command
          @payment_gateway = payment_gateway
        end

        def call
          validation_failure = validate_submission
          return validation_failure if validation_failure

          payment_result = capture_or_confirm_payment
          return payment_failure(payment_result) if payment_result.failure?

          success_checkpoint_result = success_checkpoint(payment_result.data.fetch(:payment))
          return success_checkpoint_result if success_checkpoint_result.failure?

          success_checkpoint_result
        rescue AASM::InvalidTransition, ActiveRecord::RecordInvalid => e
          Core::Result::Failure.(message: e.message, code: :invalid_record, data: { submission: submission, order_id: submission.order&.id })
        end

        private

        attr_reader :submission, :payment_command, :payment_gateway

        def validate_submission
          return failure("Submission requires an order", :invalid_record) if submission.order.nil?
          return failure("Submission requires a fulfillment account", :invalid_record) if submission.fulfillment_account.nil?
          return failure("Submission requires at least one line item", :invalid_record) if submission.line_items.empty?
          return failure("Order is not ready for submission", :invalid_record) if submission_ready_state? == false

          nil
        end

        def submission_ready_state?
          order = submission.order

          return order.submitted? if order.respond_to?(:submitted?)
          return order.placed? if order.respond_to?(:placed?)
          return order.confirmed? if order.respond_to?(:confirmed?)

          true
        end

        def capture_or_confirm_payment
          payment_command.(
            order: submission.order,
            provider: submission.payment_provider,
            payment_method_type: submission.payment_method_type,
            gateway: payment_gateway
          )
        end

        def success_checkpoint(payment)
          return failure("Payment must be active before success checkpoint", :invalid_record) unless payment.active?

          enqueue_follow_up_work(payment)

          Core::Result::Success.(data: { payment: payment, order: submission.order, submission: submission })
        end

        def enqueue_follow_up_work(payment)
          Payments::Application::Handlers::GenerateInvoiceJob.perform_later(payment.id)
          NotificationJob.perform_later(submission.order.id)
        end

        def payment_failure(payment_result)
          Core::Result::Failure.(
            message: payment_result.message,
            code: payment_result.code,
            data: payment_result.data.merge(submission: submission, order: submission.order)
          )
        end

        def failure(message, code)
          Core::Result::Failure.(message: message, code: code, data: { submission: submission, order: submission.order })
        end
      end
    end
  end
end
