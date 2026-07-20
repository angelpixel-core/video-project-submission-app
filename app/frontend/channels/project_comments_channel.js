import { refreshProjectComments } from "../lib/project_comments_refresh"

export function subscribeToProjectComments(consumer) {
  const projectCommentsHost = document.querySelector("#project-comments")
  const projectId = projectCommentsHost?.closest("[data-project-id]")?.dataset.projectId

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
          await refreshProjectComments()
        }
      }
    }
  )
}
