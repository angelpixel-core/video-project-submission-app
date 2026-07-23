module Projects
  module Notifications
    class Delivery
      def self.call(project:, event_type:)
        new(project:, event_type:).call
      end

      def initialize(project:, event_type:)
        @project = project
        @event_type = event_type.to_s
      end

      def call
        ClientNotificationMailer.public_send(event_type, project).deliver_now
        PMNotificationMailer.public_send(event_type, project).deliver_now
      end

      private

      attr_reader :project, :event_type
    end
  end
end
