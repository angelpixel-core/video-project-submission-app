import { refreshWorkspaceNotifications } from "./workspace_notification_refresh"

export function refreshPmWorkspace({ suppressToast = false } = {}) {
  return refreshWorkspaceNotifications({
    panelSelector: suppressToast ? null : "#pm-notifications-panel",
    dropdownSelector: "#pm-notifications-dropdown",
    badgeSelector: ".pm-notifications-badge",
    menuListSelector: "#pm-notifications-menu-list",
    tableBodySelector: "#pm-projects-table-body"
  })
}

export function forceRefreshPmWorkspace({ suppressToast = false } = {}) {
  return refreshWorkspaceNotifications({
    panelSelector: suppressToast ? null : "#pm-notifications-panel",
    dropdownSelector: "#pm-notifications-dropdown",
    badgeSelector: ".pm-notifications-badge",
    menuListSelector: "#pm-notifications-menu-list",
    tableBodySelector: "#pm-projects-table-body",
    force: true
  })
}
