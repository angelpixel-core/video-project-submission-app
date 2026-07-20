import { refreshWorkspaceNotifications } from "./workspace_notification_refresh"

export function refreshClientWorkspace() {
  return refreshWorkspaceNotifications({
    panelSelector: "#client-notifications-panel",
    dropdownSelector: "#client-notifications-dropdown",
    badgeSelector: ".client-notifications-badge",
    menuListSelector: "#client-notifications-menu-list"
  })
}
