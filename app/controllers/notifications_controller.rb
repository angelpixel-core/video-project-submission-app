class NotificationsController < ApplicationController
  def update
    notification = find_notification
    notification.mark_as_read!

    head :no_content
  end

  private

  def find_notification
    current_client.notifications.find_by(id: params[:id]) || default_pm.notifications.find_by(id: params[:id]) ||
      raise(ActiveRecord::RecordNotFound)
  end
end
