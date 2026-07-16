import { Controller } from "@hotwired/stimulus"
import Modal from "bootstrap/js/dist/modal"

export default class extends Controller {
  static targets = [
    "form",
    "name",
    "rawFootageUrl",
    "selectionsJson",
    "cartItems",
    "cartTotal",
    "paymentModal",
    "paymentName",
    "paymentEmail",
    "paymentCardNumber",
    "paymentCardExpiry",
    "paymentCardCvc",
    "finalize",
  ]

  connect() {
    this.modal = this.hasPaymentModalTarget ? new Modal(this.paymentModalTarget) : null
    this.projectId = this.element.dataset.projectId
    this.autosaveTimer = null
    this.suspendAutosave = false
    this.cart = this.loadDraftState()
    this.restoreInputs()
    this.renderCart()
  }

  addSelection(event) {
    event.preventDefault()

    const button = event.currentTarget
    const videoTypeId = Number(button.dataset.videoTypeId)
    const videoTypeName = button.dataset.videoTypeName
    const priceCents = Number(button.dataset.priceCents)
    const quantityInput = button.closest("[data-order-form-video-type-card]").querySelector("[data-order-form-quantity-input]")
    const quantity = Number(quantityInput.value || 1)

    if (videoTypeId <= 0 || quantity <= 0) return

    const existing = this.cart.items.find((item) => item.videoTypeId === videoTypeId)
    if (existing) {
      existing.quantity += quantity
    } else {
      this.cart.items.push({ videoTypeId, videoTypeName, priceCents, quantity })
    }

    quantityInput.value = 1
    this.scheduleAutosave()
    this.renderCart()
  }

  removeSelection(event) {
    event.preventDefault()

    const videoTypeId = Number(event.currentTarget.dataset.videoTypeId)
    this.cart.items = this.cart.items.filter((item) => item.videoTypeId !== videoTypeId)
    this.scheduleAutosave()
    this.renderCart()
  }

  syncFields() {
    this.cart.name = this.nameTarget.value
    this.cart.rawFootageUrl = this.rawFootageUrlTarget.value
    if (this.hasPaymentNameTarget) this.cart.paymentName = this.paymentNameTarget.value
    if (this.hasPaymentEmailTarget) this.cart.paymentEmail = this.paymentEmailTarget.value
    this.scheduleAutosave()
    this.renderCart()
  }

  openPaymentModal(event) {
    event.preventDefault()
    this.syncFields()

    if (this.cart.items.length === 0) {
      this.element.querySelector("[data-order-form-status]").textContent = "Add at least one video type before paying."
      return
    }

    this.modal?.show()
  }

  prepareSubmit() {
    this.syncFields()
    const selections = this.cart.items.map((item) => ({
      video_type_id: item.videoTypeId,
      quantity: item.quantity,
    }))

    this.selectionsJsonTarget.value = JSON.stringify(selections)
    if (this.hasFinalizeTarget) this.finalizeTarget.value = "1"
  }

  submit(event) {
    this.suspendAutosave = true
    window.clearTimeout(this.autosaveTimer)
    this.prepareSubmit()

    if (this.cart.items.length === 0) {
      event.preventDefault()
      this.suspendAutosave = false
      if (this.hasFinalizeTarget) this.finalizeTarget.value = "0"
      this.element.querySelector("[data-order-form-status]").textContent = "Add at least one video type before submitting."
    }
  }

  restoreInputs() {
    this.nameTarget.value = this.cart.name || this.nameTarget.value
    this.rawFootageUrlTarget.value = this.cart.rawFootageUrl || this.rawFootageUrlTarget.value
    this.paymentNameTarget.value = this.cart.paymentName || this.paymentNameTarget.value
    this.paymentEmailTarget.value = this.cart.paymentEmail || this.paymentEmailTarget.value
    this.renderCart()
  }

  loadDraftState() {
    const fallback = { name: "", rawFootageUrl: "", paymentName: "", paymentEmail: "", items: [] }
    const rawSelections = this.selectionsJsonTarget?.value

    try {
      return {
        ...fallback,
        name: this.nameTarget?.value || "",
        rawFootageUrl: this.rawFootageUrlTarget?.value || "",
        paymentName: this.paymentNameTarget?.value || "",
        paymentEmail: this.paymentEmailTarget?.value || "",
        items: rawSelections ? JSON.parse(rawSelections).map((item) => ({
          videoTypeId: Number(item.video_type_id),
          videoTypeName: item.video_type_name || "",
          priceCents: Number(item.price_cents || 0),
          quantity: Number(item.quantity || 0),
        })) : [],
      }
    } catch {
      return fallback
    }
  }

  renderCart() {
    const selections = this.cart.items.map((item) => ({
      video_type_id: item.videoTypeId,
      quantity: item.quantity,
    }))

    this.selectionsJsonTarget.value = JSON.stringify(selections)

    if (this.cartItemsTarget) {
      this.cartItemsTarget.innerHTML = this.cart.items.length
        ? this.cart.items.map((item) => `
          <li class="list-group-item d-flex justify-content-between align-items-start">
            <div class="me-2">
              <div class="fw-semibold">${this.escapeHtml(item.videoTypeName)}</div>
              <small class="text-body-secondary">Qty ${item.quantity} · $${(item.priceCents / 100).toFixed(2)} each</small>
            </div>
            <button class="btn btn-sm btn-outline-danger" type="button" data-video-type-id="${item.videoTypeId}" data-action="click->order-form#removeSelection">Remove</button>
          </li>
        `).join("")
        : '<li class="list-group-item text-body-secondary">No selections yet.</li>'
    }

    if (this.hasCartTotalTarget) {
      const total = this.cart.items.reduce((sum, item) => sum + (item.priceCents * item.quantity), 0)
      this.cartTotalTargets.forEach((target) => {
        target.textContent = `$${(total / 100).toFixed(2)}`
      })
    }
  }

  scheduleAutosave() {
    if (!this.projectId || this.suspendAutosave) return

    window.clearTimeout(this.autosaveTimer)
    this.autosaveTimer = window.setTimeout(() => {
      this.autosave()
    }, 200)
  }

  autosave() {
    if (!this.projectId) return

    const formData = new FormData(this.formTarget)
    formData.set("project[selections_json]", JSON.stringify(this.cart.items.map((item) => ({
      video_type_id: item.videoTypeId,
      quantity: item.quantity,
    }))))
    formData.set("project[finalize]", "0")

    const token = document.querySelector('meta[name="csrf-token"]')?.content

    fetch(`/projects/${this.projectId}`, {
      method: "PATCH",
      headers: {
        Accept: "text/html",
        "X-CSRF-Token": token || "",
      },
      body: formData,
    }).catch(() => {})
  }

  escapeHtml(value) {
    const div = document.createElement("div")
    div.textContent = value
    return div.innerHTML
  }
}
