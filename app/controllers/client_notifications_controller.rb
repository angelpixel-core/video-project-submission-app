class ClientNotificationsController < ApplicationController
  def update
    notification = current_client.notifications.find(params[:id])
    notification.mark_as_read!

    head :no_content
  end
end
