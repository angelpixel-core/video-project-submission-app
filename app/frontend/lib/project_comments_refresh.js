export function insertProjectComment(data) {
  const commentsList = document.querySelector("#project-comments-list")
  const commentsEmptyState = document.querySelector("#project-comments-empty")
  const commentsCount = document.querySelector("#project-comments-count")

  if (!commentsList || !data?.comment_html) return

  if (commentsEmptyState) commentsEmptyState.remove()

  commentsList.insertAdjacentHTML("beforeend", data.comment_html)

  if (commentsCount && typeof data.comment_count === "number") {
    commentsCount.textContent = String(data.comment_count)
  }
}
