import { insertProjectComment } from "../lib/project_comments_refresh"

export function subscribeToProjectComments(consumer) {
  const projectCommentsHost = document.querySelector("#order-comments")
  const projectId = projectCommentsHost?.closest("[data-order-id]")?.dataset.orderId

  if (!projectId || !projectCommentsHost) return null

  return consumer.subscriptions.create(
    { channel: "ProjectCommentsChannel", project_id: projectId },
    {
      connected() {
        document.documentElement.dataset.projectCommentsConnected = "true"
      },

      async received(data) {
        document.documentElement.dataset.projectCommentsReceived = data?.type || "unknown"

        if (data?.type === "comments_updated") {
          insertProjectComment(data)
        }
      }
    }
  )
}
