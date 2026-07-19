const PANEL_SELECTORS = ["#pm-notifications-panel"]
const DROPDOWN_SELECTOR = "#pm-notifications-dropdown"
const BADGE_SELECTOR = ".pm-notifications-badge"
const MENU_LIST_SELECTOR = "#pm-notifications-menu-list"

async function refreshPanel() {
  const currentPanels = PANEL_SELECTORS
    .map((selector) => [selector, document.querySelector(selector)])
    .filter(([, panel]) => panel)

  const currentDropdown = document.querySelector(DROPDOWN_SELECTOR)
  if (currentPanels.length === 0 && !currentDropdown) return

  const response = await fetch(window.location.href, { headers: { Accept: "text/html" } })
  if (!response.ok) return

  const html = await response.text()
  const documentFragment = new DOMParser().parseFromString(html, "text/html")
  currentPanels.forEach(([selector, currentPanel]) => {
    const nextPanel = documentFragment.querySelector(selector)
    if (currentPanel && nextPanel) currentPanel.outerHTML = nextPanel.outerHTML
  })

  const nextDropdown = documentFragment.querySelector(DROPDOWN_SELECTOR)
  if (currentDropdown && nextDropdown) {
    const currentBadge = currentDropdown.querySelector(BADGE_SELECTOR)
    const nextBadge = nextDropdown.querySelector(BADGE_SELECTOR)
    if (currentBadge && nextBadge) currentBadge.textContent = nextBadge.textContent

    const currentMenuList = currentDropdown.querySelector(MENU_LIST_SELECTOR)
    const nextMenuList = nextDropdown.querySelector(MENU_LIST_SELECTOR)
    if (currentMenuList && nextMenuList) currentMenuList.innerHTML = nextMenuList.innerHTML
  }
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
