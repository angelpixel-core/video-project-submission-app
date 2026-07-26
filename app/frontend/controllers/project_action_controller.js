import { Controller } from "@hotwired/stimulus"
import { forceRefreshWorkspace } from "../lib/workspace_refresh"

export default class ProjectActionController extends Controller {
  async submit(event) {
    event.preventDefault()

    const submitter = event.submitter
    if (submitter) submitter.disabled = true

    try {
      await fetch(this.element.action, {
        method: "POST",
        headers: {
          "X-PM-Async-Action": "1"
        },
        body: new FormData(this.element)
      })

      await new Promise((resolve) => window.setTimeout(resolve, 50))
      await forceRefreshWorkspace({ role: "pm" })
      await new Promise((resolve) => window.setTimeout(resolve, 50))
      await forceRefreshWorkspace({ role: "pm" })
    } catch {
      // If the async path fails, the next refresh or navigation will restore state.
    } finally {
      if (submitter && !submitter.disabled) return
      if (submitter) submitter.disabled = false
    }
  }
}
