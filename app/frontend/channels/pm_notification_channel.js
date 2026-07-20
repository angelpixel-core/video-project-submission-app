import { refreshPmWorkspace } from "../lib/pm_workspace_refresh"
import { shouldSuppressNotificationToast } from "../lib/workspace_notification_refresh"

export function subscribeToPMNotifications(consumer) {
  return consumer.subscriptions.create({ channel: "PMNotificationChannel" }, {
    connected() {
      document.documentElement.dataset.pmNotificationsConnected = "true"
    },

    async received(data) {
      document.documentElement.dataset.pmNotificationsReceived = data?.type || "unknown"

      if (data?.type === "notifications_updated") {
        await refreshPmWorkspace({ suppressToast: shouldSuppressNotificationToast(data) })
      }
    }
  })
}
