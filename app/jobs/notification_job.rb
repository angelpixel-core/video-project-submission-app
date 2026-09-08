# TODO(cleanup): Move this job under the Notifications boundary once the
# notification delivery contract is stable. This top-level class is retained
# as a compatibility adapter for existing ordering and fulfillment callsites.
class NotificationJob < ApplicationJob
  def perform(project_id)
    Orders::Notifications::Service.call(project: Order.find(project_id), event_type: :project_created)
  end
end
