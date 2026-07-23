module Projects
  module Notifications
    class Service
      def initialize(project_id)
        @project_id = project_id
      end

      def call
        project = load_project

        create_notification(project)
        Projects::Notifications::Dispatcher.call(project: project, event_type: :project_created)
      end

      private

      attr_reader :project_id

      def load_project
        Project.includes(:pm_account).find(project_id)
      end

      def create_notification(project)
        Notification.create!(
          project: project,
          pm: project.pm,
          kind: "project_created",
          body: "Project #{project.name} submitted for review"
        )
      end
    end
  end
end
