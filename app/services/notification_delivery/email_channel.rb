module NotificationDelivery
  class EmailChannel
    def initialize(project)
      @project = project
    end

    def call
      PMNotificationMailer.project_created(project).deliver_now
    end

    private

    attr_reader :project
  end
end
