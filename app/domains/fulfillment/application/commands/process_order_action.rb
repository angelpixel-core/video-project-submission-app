module Fulfillment
  module Application
    module Commands
      class ProcessOrderAction
        def self.call(order:, event:)
          new(order:, event:).call
        end

        def initialize(order:, event:)
          @order = order
          @event = event.to_sym
        end

        def call
          return unsupported_event_failure unless allowed_events.include?(event)

          order.with_lock do
            return stale_failure unless order.public_send("may_#{event}?")

            perform_action!

            Core::Result::Success.(data: { broadcast_refresh: broadcast_refresh? })
          end
        rescue AASM::InvalidTransition, ActiveRecord::RecordInvalid => e
          Core::Result::Failure.(message: e.message, code: :invalid_transition, data: { project_id: order.id })
        end

        private

        attr_reader :order, :event

        def allowed_events
          %i[accept complete]
        end

        def broadcast_refresh?
          event == :accept
        end

        def perform_action!
          order.public_send("#{event}!")
        end

        def unsupported_event_failure
          Core::Result::Failure.(message: "Unsupported fulfillment action.", code: :invalid_action, data: { project_id: order.id })
        end

        def stale_failure
          Core::Result::Failure.(message: "Fulfillment action is stale.", code: :invalid_transition, data: { project_id: order.id })
        end
      end
    end
  end
end
