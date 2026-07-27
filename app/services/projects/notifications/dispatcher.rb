module Projects
  module Notifications
    class Dispatcher < Core::Services::Notifications::Dispatcher
      def initialize(project:, event_type:)
        @project = project
        @event_type = event_type.to_s
      end

      private

      attr_reader :project, :event_type

      def delivery_channels
        [
          Channel::Logger.new(project),
          Channel::Email.new(project, event_type)
        ]
      end
    end
  end
end
