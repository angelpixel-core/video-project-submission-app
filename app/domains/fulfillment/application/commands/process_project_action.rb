module Fulfillment
  module Application
    module Commands
      class ProcessProjectAction
        def self.call(project:, event:)
          new(project:, event:).call
        end

        def initialize(project:, event:)
          @project = project
          @event = event.to_sym
        end

        def call
          return unsupported_event_failure unless allowed_events.include?(event)

          project.with_lock do
            return stale_failure unless project.public_send("may_#{event}?")

            perform_action!

            Core::Result::Success.(data: { broadcast_refresh: broadcast_refresh? })
          end
        rescue AASM::InvalidTransition, ActiveRecord::RecordInvalid => e
          Core::Result::Failure.(message: e.message, code: :invalid_transition, data: { project_id: project.id })
        end

        private

        attr_reader :project, :event

        def allowed_events
          %i[accept complete]
        end

        def broadcast_refresh?
          event == :accept
        end

        def perform_action!
          project.public_send("#{event}!")
        end

        def unsupported_event_failure
          Core::Result::Failure.(message: "Unsupported project action.", code: :invalid_action, data: { project_id: project.id })
        end

        def stale_failure
          Core::Result::Failure.(message: "Project action is stale.", code: :invalid_transition, data: { project_id: project.id })
        end
      end
    end
  end
end
