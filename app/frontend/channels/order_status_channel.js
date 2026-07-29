export function subscribeToOrderStatus(consumer) {
  const orderBadgeNodes = document.querySelectorAll("[id^='status_badge_']")

  if (!orderBadgeNodes.length) return null

  return Array.from(orderBadgeNodes).map((badgeNode) => {
    const orderContainer = badgeNode.closest("[data-order-id]")
    const orderId = orderContainer?.dataset.orderId

    if (!orderId) return null

    return consumer.subscriptions.create(
      { channel: "OrderStatusChannel", project_id: orderId },
      {
      connected() {
        document.documentElement.dataset.orderStatusConnected = "true"
      },

      received(data) {
        document.documentElement.dataset.orderStatusReceived = data?.type || "unknown"

          if (data?.type === "status_updated" && data.project_id?.toString() === orderId) {
            badgeNode.innerHTML = data.status_badge_html
          }
        }
      }
    )
  })
}
