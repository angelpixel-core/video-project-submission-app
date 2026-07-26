module Projects
  class ActionService
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

      case event
      when :accept
        project.notifications.unread.update_all(read_at: Time.current)
        create_client_status_notification!(
          kind: "project_accepted",
          body: "Your project #{project.name.presence || 'Untitled project'} was accepted and is now in progress."
        )
        Projects::Notifications::Dispatcher.call(project: project, event_type: :project_accepted)
      when :complete
        create_client_status_notification!(
          kind: "project_completed",
          body: "Your project #{project.name.presence || 'Untitled project'} has been completed."
        )
      end
    end

    def create_client_status_notification!(kind:, body:)
      Notification.create!(project: project, client: project.owner, kind: kind, body: body)
    end

    def unsupported_event_failure
      Core::Result::Failure.(message: "Unsupported project action.", code: :invalid_action, data: { project_id: project.id })
    end

    def stale_failure
      Core::Result::Failure.(message: "Project action is stale.", code: :invalid_transition, data: { project_id: project.id })
    end
  end
end
