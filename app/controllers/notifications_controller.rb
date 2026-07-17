class NotificationsController < ApplicationController
  def update
    notification = default_pm.notifications.find(params[:id])
    notification.mark_as_read!

    redirect_to projects_path, notice: "Notification acknowledged."
  end
end
