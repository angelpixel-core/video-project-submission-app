export function subscribeToProjectStatus(consumer) {
  const projectBadgeNodes = document.querySelectorAll("[id^='status_badge_']")

  if (!projectBadgeNodes.length) return null

  return Array.from(projectBadgeNodes).map((badgeNode) => {
    const projectContainer = badgeNode.closest("[data-order-id]")
    const projectId = projectContainer?.dataset.orderId

    if (!projectId) return null

    return consumer.subscriptions.create(
      { channel: "ProjectStatusChannel", project_id: projectId },
      {
        connected() {
          document.documentElement.dataset.projectStatusConnected = "true"
        },

        received(data) {
          document.documentElement.dataset.projectStatusReceived = data?.type || "unknown"

          if (data?.type === "status_updated" && data.project_id?.toString() === projectId) {
            badgeNode.innerHTML = data.status_badge_html
          }
        }
      }
    )
  })
}
