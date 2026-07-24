import { refreshClientWorkspace, refreshPmWorkspace } from "../lib/workspace_refresh"
import { shouldSuppressNotificationToast } from "../lib/workspace_notification_refresh"

export function subscribeToNotifications(consumer, { role }) {
  const connectedKey = role === "pm" ? "pmNotificationsConnected" : "clientNotificationsConnected"
  const receivedKey = role === "pm" ? "pmNotificationsReceived" : "clientNotificationsReceived"

  return consumer.subscriptions.create({ channel: "NotificationsChannel", role }, {
    connected() {
      document.documentElement.dataset[connectedKey] = "true"
    },

    async received(data) {
      document.documentElement.dataset[receivedKey] = data?.type || "unknown"

      if (data?.type === "notifications_updated") {
        const suppressToast = shouldSuppressNotificationToast(data)
        if (role === "pm") {
          await refreshPmWorkspace({ suppressToast })
        } else {
          await refreshClientWorkspace({ suppressToast })
        }
      }
    }
  })
}

export function subscribeToClientNotifications(consumer) {
  return subscribeToNotifications(consumer, { role: "client" })
}

export function subscribeToPMNotifications(consumer) {
  return subscribeToNotifications(consumer, { role: "pm" })
}
