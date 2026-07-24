import { refreshWorkspaceNotifications } from "./workspace_notification_refresh"

export function refreshWorkspace({ role, suppressToast = false } = {}) {
  const config = role === "pm"
    ? {
        panelSelector: suppressToast ? null : "#pm-notifications-panel",
        dropdownSelector: "#pm-notifications-dropdown",
        badgeSelector: ".pm-notifications-badge",
        menuListSelector: "#pm-notifications-menu-list",
        tableBodySelector: "#pm-projects-table-body"
      }
    : {
        panelSelector: suppressToast ? null : "#client-notifications-panel",
        dropdownSelector: "#client-notifications-dropdown",
        badgeSelector: ".client-notifications-badge",
        menuListSelector: "#client-notifications-menu-list"
      }

  return refreshWorkspaceNotifications(config)
}

export function refreshClientWorkspace(options = {}) {
  return refreshWorkspace({ role: "client", ...options })
}

export function refreshPmWorkspace(options = {}) {
  return refreshWorkspace({ role: "pm", ...options })
}

export function forceRefreshPmWorkspace(options = {}) {
  return refreshWorkspace({ role: "pm", ...options, force: true })
}
