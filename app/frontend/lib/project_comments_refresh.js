let refreshPromise = null

export async function refreshProjectComments() {
  if (refreshPromise) return refreshPromise

  refreshPromise = (async () => {
    const currentComments = document.querySelector("#project-comments")
    if (!currentComments) return

    const response = await fetch(window.location.href, { headers: { Accept: "text/html" } })
    if (!response.ok) return

    const html = await response.text()
    const documentFragment = new DOMParser().parseFromString(html, "text/html")
    const nextComments = documentFragment.querySelector("#project-comments")
    if (nextComments) currentComments.outerHTML = nextComments.outerHTML
  })()

  try {
    await refreshPromise
  } finally {
    refreshPromise = null
  }
}
