module Orders
  class ActionService
    def self.call(project:, event:)
      result = Fulfillment::Application::Commands::ProcessProjectAction.call(project:, event:)

      if result.success?
        Orders::Notifications::Service.call(project:, event_type: notification_event_type_for(event))
      end

      result
    end

    def self.notification_event_type_for(event)
      case event.to_sym
      when :accept
        :project_accepted
      when :complete
        :project_completed
      end
    end
  end
end
