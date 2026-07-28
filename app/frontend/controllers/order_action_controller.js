import { Controller } from "@hotwired/stimulus"

export default class OrderActionController extends Controller {
  async submit(event) {
    event.preventDefault()

    const submitter = event.submitter
    if (submitter) submitter.disabled = true

    try {
      const response = await fetch(this.element.action, {
        method: "POST",
        headers: {
          "X-Workspace-Async-Action": "1"
        },
        body: new FormData(this.element)
      })

      if (response.ok) {
        const data = await response.json()
        const currentRow = this.element.closest("tr")

        if (currentRow) {
          const statusBadge = currentRow.querySelector("td:nth-child(5) .badge")
          if (statusBadge) {
            statusBadge.textContent = data.status_badge_text
            statusBadge.className = `badge ${data.status_badge_class} text-white text-uppercase`
          }

          const actionCell = currentRow.querySelector("td:nth-child(6)")
          if (actionCell) actionCell.innerHTML = buildActionMarkup({ orderId: data.project_id, action: data.action })
        }
      }
    } catch {
      // If the async path fails, the next refresh or navigation will restore state.
    } finally {
      if (submitter && !submitter.disabled) return
      if (submitter) submitter.disabled = false
    }
  }
}

function buildActionMarkup({ orderId, action }) {
  if (action === "complete") {
    return `
      <div class="d-inline-flex flex-wrap gap-2 justify-content-end">
        <form data-controller="order-action" data-action="submit->order-action#submit" class="button_to" method="post" action="/orders/${orderId}/complete">
          <input type="hidden" name="_method" value="patch" />
          <button class="btn btn-sm btn-outline-success" type="submit">Marcar como completado</button>
        </form>
      </div>
    `
  }

  return "<div class=\"d-inline-flex flex-wrap gap-2 justify-content-end\"></div>"
}
