module Projects
  module Notifications
    module Channel
      class Logger < Core::Services::Notifications::Channel
        def initialize(project)
          @project = project
        end

        def call
          Rails.logger.info("Notification for PM #{project.pm.email}: project #{project.id} was created")
        end

        private

        attr_reader :project
      end
    end
  end
end
