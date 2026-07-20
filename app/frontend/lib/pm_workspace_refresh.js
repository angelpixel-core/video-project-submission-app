import { refreshWorkspaceNotifications } from "./workspace_notification_refresh"

export function refreshPmWorkspace() {
  return refreshWorkspaceNotifications({
    panelSelector: "#pm-notifications-panel",
    dropdownSelector: "#pm-notifications-dropdown",
    badgeSelector: ".pm-notifications-badge",
    menuListSelector: "#pm-notifications-menu-list",
    tableBodySelector: "#pm-projects-table-body"
  })
}

export function forceRefreshPmWorkspace() {
  return refreshWorkspaceNotifications({
    panelSelector: "#pm-notifications-panel",
    dropdownSelector: "#pm-notifications-dropdown",
    badgeSelector: ".pm-notifications-badge",
    menuListSelector: "#pm-notifications-menu-list",
    tableBodySelector: "#pm-projects-table-body",
    force: true
  })
}
