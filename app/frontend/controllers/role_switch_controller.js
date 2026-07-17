import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "workspace-mode"
const VALID_MODES = new Set(["client", "pm"])

export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.mode = this.loadMode()
    this.applyMode(this.mode)
  }

  select(event) {
    this.applyMode(event.currentTarget.dataset.mode)
  }

  loadMode() {
    try {
      const storedMode = window.sessionStorage.getItem(STORAGE_KEY)
      return VALID_MODES.has(storedMode) ? storedMode : "client"
    } catch {
      return "client"
    }
  }

  applyMode(mode) {
    const nextMode = VALID_MODES.has(mode) ? mode : "client"
    this.mode = nextMode
    this.element.dataset.roleMode = nextMode
    document.documentElement.dataset.roleMode = nextMode

    try {
      window.sessionStorage.setItem(STORAGE_KEY, nextMode)
    } catch {
      // Session storage can be blocked in some browsers; the UI still works.
    }

    this.buttonTargets.forEach((button) => {
      const isActive = button.dataset.mode === nextMode
      button.classList.toggle("btn-primary", isActive)
      button.classList.toggle("btn-outline-primary", !isActive)
      button.setAttribute("aria-pressed", String(isActive))
    })
  }
}
