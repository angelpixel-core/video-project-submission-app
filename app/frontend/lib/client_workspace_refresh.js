import { refreshWorkspaceNotifications } from "./workspace_notification_refresh"

export function refreshClientWorkspace({ suppressToast = false } = {}) {
  return refreshWorkspaceNotifications({
    panelSelector: suppressToast ? null : "#client-notifications-panel",
    dropdownSelector: "#client-notifications-dropdown",
    badgeSelector: ".client-notifications-badge",
    menuListSelector: "#client-notifications-menu-list"
  })
}
