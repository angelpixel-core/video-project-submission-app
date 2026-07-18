const PANEL_SELECTOR = "#pm-notifications-panel"

async function refreshPanel() {
  const currentPanel = document.querySelector(PANEL_SELECTOR)
  if (!currentPanel) return

  const response = await fetch(window.location.href, { headers: { Accept: "text/html" } })
  if (!response.ok) return

  const html = await response.text()
  const documentFragment = new DOMParser().parseFromString(html, "text/html")
  const nextPanel = documentFragment.querySelector(PANEL_SELECTOR)
  if (!nextPanel) return

  currentPanel.outerHTML = nextPanel.outerHTML
}

export function subscribeToPMNotifications(consumer) {
  return consumer.subscriptions.create({ channel: "PMNotificationChannel" }, {
    connected() {
      document.documentElement.dataset.pmNotificationsConnected = "true"
    },

    received(data) {
      document.documentElement.dataset.pmNotificationsReceived = data?.type || "unknown"

      if (data?.type === "pm_notifications_updated") {
        refreshPanel()
      }
    }
  })
}
