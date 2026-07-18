class PMNotificationChannel < ApplicationCable::Channel
  def subscribed
    stream_from "pm_notifications"
  end
end
