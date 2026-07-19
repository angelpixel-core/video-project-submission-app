class NotificationsController < ApplicationController
  def update
    notification = default_pm.notifications.find(params[:id])
    notification.mark_as_read!

    head :no_content
  end
end
