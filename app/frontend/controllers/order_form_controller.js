import { Controller } from "@hotwired/stimulus"
import Modal from "bootstrap/js/dist/modal"

const STORAGE_KEY = "video-project-order-form"

export default class extends Controller {
  static targets = [
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
  ]

  connect() {
    this.modal = this.hasPaymentModalTarget ? new Modal(this.paymentModalTarget) : null
    this.cart = this.loadState()
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
    this.persistState()
    this.renderCart()
  }

  removeSelection(event) {
    event.preventDefault()

    const videoTypeId = Number(event.currentTarget.dataset.videoTypeId)
    this.cart.items = this.cart.items.filter((item) => item.videoTypeId !== videoTypeId)
    this.persistState()
    this.renderCart()
  }

  syncFields() {
    this.cart.name = this.nameTarget.value
    this.cart.rawFootageUrl = this.rawFootageUrlTarget.value
    if (this.hasPaymentNameTarget) this.cart.paymentName = this.paymentNameTarget.value
    if (this.hasPaymentEmailTarget) this.cart.paymentEmail = this.paymentEmailTarget.value
    this.persistState()
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
    this.selectionsJsonTarget.value = JSON.stringify(this.cart.items)
  }

  submit(event) {
    this.prepareSubmit()

    if (this.cart.items.length === 0) {
      event.preventDefault()
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

  loadState() {
    const fallback = { name: "", rawFootageUrl: "", paymentName: "", paymentEmail: "", items: [] }

    try {
      const raw = sessionStorage.getItem(STORAGE_KEY)
      return raw ? { ...fallback, ...JSON.parse(raw) } : fallback
    } catch {
      return fallback
    }
  }

  persistState() {
    sessionStorage.setItem(STORAGE_KEY, JSON.stringify(this.cart))
  }

  renderCart() {
    this.selectionsJsonTarget.value = JSON.stringify(this.cart.items)

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

  escapeHtml(value) {
    const div = document.createElement("div")
    div.textContent = value
    return div.innerHTML
  }
}
