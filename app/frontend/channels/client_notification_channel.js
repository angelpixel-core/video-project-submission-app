import { refreshClientWorkspace } from "../lib/client_workspace_refresh"

export function subscribeToClientNotifications(consumer) {
  return consumer.subscriptions.create({ channel: "ClientNotificationChannel" }, {
    connected() {
      document.documentElement.dataset.clientNotificationsConnected = "true"
    },

    async received(data) {
      document.documentElement.dataset.clientNotificationsReceived = data?.type || "unknown"

      if (data?.type === "notifications_updated") {
        await refreshClientWorkspace()
      }
    }
  })
}
