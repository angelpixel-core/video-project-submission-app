import { Controller } from "@hotwired/stimulus";
import Modal from "bootstrap/js/dist/modal";

export default class extends Controller {
  static targets = [
    "form",
    "name",
    "rawFootageUrl",
    "rawFootageUrlFeedback",
    "rawFootagePreview",
    "selectionsJson",
    "cartItems",
    "cartTotal",
    "reviewButton",
    "paymentModal",
    "paymentCardShell",
    "paymentCardFront",
    "paymentCardBack",
    "paymentCardName",
    "paymentCardNumberDisplay",
    "paymentCardExpiryDisplay",
    "paymentCardCvcDisplay",
    "paymentName",
    "paymentNameFeedback",
    "paymentEmail",
    "paymentCardNumber",
    "paymentCardNumberFeedback",
    "paymentCardExpiry",
    "paymentCardExpiryFeedback",
    "paymentCardCvc",
    "paymentCardCvcFeedback",
    "finalize",
    "finalizeButton",
    "finalizeButtonLabel",
    "finalizeButtonSpinner",
  ];

  connect() {
    this.modal = this.hasPaymentModalTarget
      ? new Modal(this.paymentModalTarget)
      : null;
    this.projectId = this.element.dataset.projectId;
    this.autosaveTimer = null;
    this.finalizeTimer = null;
    this.suspendAutosave = false;
    this.isFinalizing = false;
    this.isPaymentCardFlipped = false;
    this.paymentValidationAttempted = false;
    this.paymentDetailsAreValid = false;
    this.rawFootageUrlIsValid = true;
    this.cart = this.loadDraftState();
    this.restoreInputs();
    this.renderCart();
    this.bindRawFootageValidation();
    this.updatePaymentCardPreview();
    this.updateReviewButtonState();
  }

  disconnect() {
    this.unbindRawFootageValidation();
  }

  addSelection(event) {
    event.preventDefault();

    const button = event.currentTarget;
    const videoTypeId = Number(button.dataset.videoTypeId);
    const videoTypeName = button.dataset.videoTypeName;
    const priceCents = Number(button.dataset.priceCents);
    const quantityInput = button
      .closest("[data-order-form-video-type-card]")
      .querySelector("[data-order-form-quantity-input]");
    const quantity = Number(quantityInput.value || 1);

    if (videoTypeId <= 0 || quantity <= 0) return;

    const existing = this.cart.items.find(
      (item) => item.videoTypeId === videoTypeId,
    );
    if (existing) {
      existing.quantity += quantity;
    } else {
      this.cart.items.push({
        videoTypeId,
        videoTypeName,
        priceCents,
        quantity,
      });
    }

    quantityInput.value = 1;
    this.scheduleAutosave();
    this.renderCart();
    this.updateReviewButtonState();
  }

  removeSelection(event) {
    event.preventDefault();

    const videoTypeId = Number(event.currentTarget.dataset.videoTypeId);
    this.cart.items = this.cart.items.filter(
      (item) => item.videoTypeId !== videoTypeId,
    );
    this.scheduleAutosave();
    this.renderCart();
    this.updateReviewButtonState();
  }

  syncFields() {
    this.cart.name = this.nameTarget.value;
    this.cart.rawFootageUrl = this.rawFootageUrlTarget.value;
    if (this.hasPaymentNameTarget)
      this.cart.paymentName = this.paymentNameTarget.value;
    if (this.hasPaymentEmailTarget)
      this.cart.paymentEmail = this.paymentEmailTarget.value;
    this.normalizePaymentInputs();
    this.validateRawFootageUrl();
    this.validatePaymentFields();
    this.updatePaymentCardPreview();
    this.scheduleAutosave();
    this.renderCart();
    this.updateReviewButtonState();
  }

  flipPaymentCard() {
    this.isPaymentCardFlipped = true;
    this.updatePaymentCardFlipState();
  }

  unflipPaymentCard() {
    this.isPaymentCardFlipped = false;
    this.updatePaymentCardFlipState();
  }

  openPaymentModal(event) {
    event.preventDefault();
    this.syncFields();

    if (!this.canReviewProject()) return;

    this.modal?.show();
  }

  beginFinalize(event) {
    event.preventDefault();

    if (!this.canReviewProject() || this.isFinalizing) return;

    if (!this.validatePaymentFields({ showErrors: true })) return;

    this.suspendAutosave = true;
    window.clearTimeout(this.autosaveTimer);
    this.isFinalizing = true;
    this.setFinalizeButtonLoading(true);
    window.clearTimeout(this.finalizeTimer);
    this.finalizeTimer = window.setTimeout(() => {
      this.prepareSubmit();
      this.formTarget.requestSubmit();
    }, 3000);
  }

  prepareSubmit() {
    this.syncFields();
    const selections = this.cart.items.map((item) => ({
      video_type_id: item.videoTypeId,
      quantity: item.quantity,
    }));

    this.selectionsJsonTarget.value = JSON.stringify(selections);
    if (this.hasFinalizeTarget) this.finalizeTarget.value = "1";
  }

  submit(event) {
    this.suspendAutosave = true;
    window.clearTimeout(this.autosaveTimer);
    this.prepareSubmit();

    if (!this.canReviewProject()) {
      event.preventDefault();
      this.suspendAutosave = false;
      this.isFinalizing = false;
      this.setFinalizeButtonLoading(false);
      if (this.hasFinalizeTarget) this.finalizeTarget.value = "0";
      this.element.querySelector("[data-order-form-status]").textContent =
        this.getReviewBlockReason();
    }
  }

  restoreInputs() {
    this.nameTarget.value = this.cart.name || this.nameTarget.value;
    this.rawFootageUrlTarget.value =
      this.cart.rawFootageUrl || this.rawFootageUrlTarget.value;
    this.paymentNameTarget.value =
      this.cart.paymentName || this.paymentNameTarget.value;
    this.paymentEmailTarget.value =
      this.cart.paymentEmail || this.paymentEmailTarget.value;
    this.normalizePaymentInputs();
    this.validateRawFootageUrl();
    this.validatePaymentFields();
    this.updatePaymentCardPreview();
    this.renderCart();
    this.updateReviewButtonState();
  }

  loadDraftState() {
    const fallback = {
      name: "",
      rawFootageUrl: "",
      paymentName: "",
      paymentEmail: "",
      items: [],
    };
    const rawSelections = this.selectionsJsonTarget?.value;

    try {
      return {
        ...fallback,
        name: this.nameTarget?.value || "",
        rawFootageUrl: this.rawFootageUrlTarget?.value || "",
        paymentName: this.paymentNameTarget?.value || "",
        paymentEmail: this.paymentEmailTarget?.value || "",
        items: rawSelections
          ? JSON.parse(rawSelections).map((item) => ({
              videoTypeId: Number(item.video_type_id),
              videoTypeName: item.video_type_name || "",
              priceCents: Number(item.price_cents || 0),
              quantity: Number(item.quantity || 0),
            }))
          : [],
      };
    } catch {
      return fallback;
    }
  }

  renderCart() {
    const selections = this.cart.items.map((item) => ({
      video_type_id: item.videoTypeId,
      quantity: item.quantity,
    }));

    this.selectionsJsonTarget.value = JSON.stringify(selections);

    if (this.cartItemsTarget) {
      this.cartItemsTarget.innerHTML = this.cart.items.length
        ? this.cart.items
            .map(
              (item) => `
          <li class="list-group-item d-flex justify-content-between align-items-start">
            <div class="me-2">
              <div class="fw-semibold">${this.escapeHtml(item.videoTypeName)}</div>
              <small class="text-body-secondary">Qty ${item.quantity} · $${(item.priceCents / 100).toFixed(2)} each</small>
            </div>
            <button class="btn btn-sm btn-outline-danger" type="button" data-video-type-id="${item.videoTypeId}" data-action="click->order-form#removeSelection">Remove</button>
          </li>
        `,
            )
            .join("")
        : '<li class="list-group-item text-body-secondary">No selections yet.</li>';
    }

    if (this.hasCartTotalTarget) {
      const total = this.cart.items.reduce(
        (sum, item) => sum + item.priceCents * item.quantity,
        0,
      );
      this.cartTotalTargets.forEach((target) => {
        target.textContent = `$${(total / 100).toFixed(2)}`;
      });
    }

    this.updateReviewButtonState();
    this.updateRawFootagePreview();
  }

  scheduleAutosave() {
    if (!this.projectId || this.suspendAutosave) return;

    window.clearTimeout(this.autosaveTimer);
    this.autosaveTimer = window.setTimeout(() => {
      this.autosave();
    }, 200);
  }

  autosave() {
    if (!this.projectId) return;

    const formData = new FormData(this.formTarget);
    formData.set(
      "project[selections_json]",
      JSON.stringify(
        this.cart.items.map((item) => ({
          video_type_id: item.videoTypeId,
          quantity: item.quantity,
        })),
      ),
    );
    formData.set("project[finalize]", "0");

    const token = document.querySelector('meta[name="csrf-token"]')?.content;

    fetch(`/projects/${this.projectId}`, {
      method: "PATCH",
      headers: {
        Accept: "text/html",
        "X-CSRF-Token": token || "",
      },
      body: formData,
    }).catch(() => {});
  }

  setFinalizeButtonLoading(loading) {
    if (!this.hasFinalizeButtonTarget) return;

    this.finalizeButtonTarget.disabled = loading;
    if (this.hasFinalizeButtonLabelTarget)
      this.finalizeButtonLabelTarget.classList.toggle("d-none", loading);
    if (this.hasFinalizeButtonSpinnerTarget)
      this.finalizeButtonSpinnerTarget.classList.toggle("d-none", !loading);
  }

  bindRawFootageValidation() {
    if (!globalThis.$ || !this.hasRawFootageUrlTarget) return;

    this.$rawFootageUrl = globalThis.$(this.rawFootageUrlTarget);
    this.$rawFootageUrl.on("blur.orderForm input.orderForm", () => {
      this.validateRawFootageUrl();
    });
  }

  unbindRawFootageValidation() {
    if (this.$rawFootageUrl) {
      this.$rawFootageUrl.off(".orderForm");
    }
  }

  validateRawFootageUrl() {
    const value = (this.rawFootageUrlTarget.value || "").trim();

    if (value === "") {
      this.rawFootageUrlIsValid = true;
      this.setRawFootageUrlFeedback("");
      this.setRawFootageUrlState(null);
      this.updateReviewButtonState();
      return true;
    }

    let parsedUrl;
    try {
      parsedUrl = new URL(value);
    } catch {
      parsedUrl = null;
    }

    const isValid = Boolean(parsedUrl && parsedUrl.protocol === "https:");
    this.rawFootageUrlIsValid = isValid;

    if (isValid) {
      this.setRawFootageUrlFeedback("");
      this.setRawFootageUrlState(true);
    } else {
      this.setRawFootageUrlFeedback("Please use a valid https:// URL.");
      this.setRawFootageUrlState(false);
    }

    this.updateReviewButtonState();
    this.updateRawFootagePreview();
    return isValid;
  }

  setRawFootageUrlFeedback(message) {
    if (!this.hasRawFootageUrlFeedbackTarget) return;

    this.rawFootageUrlFeedbackTarget.textContent = message;
    this.rawFootageUrlFeedbackTarget.classList.toggle("d-none", message === "");
  }

  setRawFootageUrlState(isValid) {
    this.rawFootageUrlTarget.classList.remove("is-valid", "is-invalid");

    if (isValid === true) this.rawFootageUrlTarget.classList.add("is-valid");
    if (isValid === false) this.rawFootageUrlTarget.classList.add("is-invalid");
  }

  setFinalizeButtonEnabled(enabled) {
    if (!this.hasFinalizeButtonTarget || this.isFinalizing) return;

    this.finalizeButtonTarget.disabled = !enabled || !this.paymentDetailsAreValid;
  }

  canReviewProject() {
    const hasName = (this.nameTarget?.value || "").trim().length > 0;
    const hasUrl = (this.rawFootageUrlTarget?.value || "").trim().length > 0;

    return (
      hasName &&
      hasUrl &&
      this.rawFootageUrlIsValid &&
      this.cart.items.length > 0
    );
  }

  getReviewBlockReason() {
    if (this.cart.items.length === 0)
      return "Add at least one video type before paying.";
    if ((this.nameTarget?.value || "").trim().length === 0)
      return "Add a project name before paying.";
    if ((this.rawFootageUrlTarget?.value || "").trim().length === 0)
      return "Add a raw footage URL before paying.";
    if (!this.rawFootageUrlIsValid)
      return "Please use a valid https:// URL before paying.";
    return "Complete the required fields before paying.";
  }

  updateReviewButtonState() {
    if (!this.hasReviewButtonTarget) return;

    const canReview = this.canReviewProject();
    const statusTarget = this.element.querySelector("[data-order-form-status]");

    this.reviewButtonTarget.disabled = !canReview;
    this.reviewButtonTarget.classList.toggle("btn-outline-primary", canReview);
    this.reviewButtonTarget.classList.toggle("btn-secondary", !canReview);
    this.reviewButtonTarget.classList.toggle("disabled", !canReview);
    if (statusTarget)
      statusTarget.textContent = canReview ? "" : this.getReviewBlockReason();
    this.setFinalizeButtonEnabled(canReview);
  }

  updatePaymentCardPreview() {
    if (!this.hasPaymentCardShellTarget) return;

    const name = (this.paymentNameTarget?.value || "").trim();
    const number = this.formatCardNumber(this.paymentCardNumberTarget?.value || "");
    const expiry = this.formatCardExpiry(this.paymentCardExpiryTarget?.value || "");
    const cvc = (this.paymentCardCvcTarget?.value || "").replace(/\D/g, "");

    if (this.hasPaymentCardNameTarget)
      this.paymentCardNameTarget.textContent = name || "Name on card";
    if (this.hasPaymentCardNumberDisplayTarget)
      this.paymentCardNumberDisplayTarget.textContent = number || "4242 4242 4242 4242";
    if (this.hasPaymentCardExpiryDisplayTarget)
      this.paymentCardExpiryDisplayTarget.textContent = expiry || "MM/YY";
    if (this.hasPaymentCardCvcDisplayTarget)
      this.paymentCardCvcDisplayTarget.textContent = cvc || "123";

    this.updatePaymentCardFlipState();
  }

  normalizePaymentInputs() {
    if (this.hasPaymentCardNumberTarget) {
      this.paymentCardNumberTarget.value = this.formatCardNumber(
        this.paymentCardNumberTarget.value,
      );
    }

    if (this.hasPaymentCardExpiryTarget) {
      this.paymentCardExpiryTarget.value = this.formatCardExpiry(
        this.paymentCardExpiryTarget.value,
      );
    }

    if (this.hasPaymentCardCvcTarget) {
      this.paymentCardCvcTarget.value = (this.paymentCardCvcTarget.value || "")
        .replace(/\D/g, "")
        .slice(0, 3);
    }
  }

  validatePaymentFields(options = {}) {
    const showErrors = options.showErrors === true;
    if (showErrors) this.paymentValidationAttempted = true;

    this.normalizePaymentInputs();

    const name = (this.paymentNameTarget?.value || "").trim();
    const numberDigits = (this.paymentCardNumberTarget?.value || "").replace(/\D/g, "");
    const expiryValue = (this.paymentCardExpiryTarget?.value || "").trim();
    const cvcDigits = (this.paymentCardCvcTarget?.value || "").replace(/\D/g, "");

    const errors = {
      name: !name ? "Name on card is required." : null,
      number: this.validateCardNumber(numberDigits),
      expiry: this.validateCardExpiry(expiryValue),
      cvc: cvcDigits.length !== 3 ? "CVC must be 3 digits." : null,
    };

    this.setPaymentFieldFeedback("paymentName", errors.name, showErrors || !!name);
    this.setPaymentFieldFeedback("paymentCardNumber", errors.number, showErrors || numberDigits.length > 0);
    this.setPaymentFieldFeedback("paymentCardExpiry", errors.expiry, showErrors || expiryValue.length > 0);
    this.setPaymentFieldFeedback("paymentCardCvc", errors.cvc, showErrors || cvcDigits.length > 0);

    this.paymentDetailsAreValid = !Object.values(errors).some(Boolean);
    this.updatePaymentCardPreview();
    this.setFinalizeButtonEnabled(this.canReviewProject());

    return this.paymentDetailsAreValid;
  }

  validatePaymentFieldsOnBlur() {
    return this.validatePaymentFields({ showErrors: true });
  }

  validateCardNumber(numberDigits) {
    if (numberDigits.length === 0) return "Card number is required.";
    if (numberDigits.length !== 16) return "Card number must be 16 digits.";

    const digits = numberDigits.split("").map((digit) => Number(digit));
    const checksum = digits
      .reverse()
      .reduce((sum, digit, index) => {
        let value = digit;
        if (index % 2 === 1) {
          value *= 2;
          if (value > 9) value -= 9;
        }
        return sum + value;
      }, 0);

    return checksum % 10 === 0 ? null : "Card number is not valid.";
  }

  validateCardExpiry(expiryValue) {
    if (expiryValue.length === 0) return "Expiry is required.";

    const match = expiryValue.match(/^(\d{2})\/(\d{2})$/);
    if (!match) return "Use MM/YY format.";

    const month = Number(match[1]);
    const year = Number(match[2]);
    if (month < 1 || month > 12) return "Expiry month must be between 01 and 12.";

    const now = new Date();
    const currentYear = Number(String(now.getFullYear()).slice(-2));
    const currentMonth = now.getMonth() + 1;

    if (year < currentYear || (year === currentYear && month < currentMonth)) {
      return "Card has expired.";
    }

    return null;
  }

  setPaymentFieldFeedback(field, message, show) {
    const feedbackTarget = this[`${field}FeedbackTarget`];
    const inputTarget = this[`${field}Target`];

    if (!inputTarget) return;

    inputTarget.classList.remove("is-valid", "is-invalid");
    if (!show) {
      if (feedbackTarget) feedbackTarget.textContent = "";
      feedbackTarget?.classList.add("d-none");
      return;
    }

    if (message) {
      inputTarget.classList.add("is-invalid");
      if (feedbackTarget) {
        feedbackTarget.textContent = message;
        feedbackTarget.classList.remove("d-none");
      }
    } else {
      inputTarget.classList.add("is-valid");
      if (feedbackTarget) {
        feedbackTarget.textContent = "";
        feedbackTarget.classList.add("d-none");
      }
    }
  }

  updatePaymentCardFlipState() {
    if (!this.hasPaymentCardShellTarget) return;

    this.paymentCardShellTarget.classList.toggle("is-flipped", this.isPaymentCardFlipped);
  }

  formatCardNumber(value) {
    return (value || "")
      .replace(/\D/g, "")
      .slice(0, 16)
      .replace(/(.{4})/g, "$1 ")
      .trim();
  }

  formatCardExpiry(value) {
    const digits = (value || "").replace(/\D/g, "").slice(0, 4);
    if (digits.length <= 2) return digits;
    return `${digits.slice(0, 2)}/${digits.slice(2)}`;
  }

  updateRawFootagePreview() {
    if (!this.hasRawFootagePreviewTarget) return;

    const preview = this.parseRawFootageUrl(this.rawFootageUrlTarget.value);

    if (!preview) {
      this.rawFootagePreviewTarget.classList.remove("is-visible");
      this.rawFootagePreviewTarget.innerHTML = "";
      return;
    }

    const providerLabel =
      preview.provider === "instagram"
        ? "Instagram preview"
        : preview.provider === "tiktok"
          ? "TikTok preview"
          :
      preview.provider === "twitch"
        ? "Twitch preview"
        : preview.provider === "vimeo"
          ? "Vimeo preview"
          : "YouTube preview";
    const shellClasses = ["raw-footage-preview-shell"];
    if (preview.aspectRatio === "9 / 16") shellClasses.push("is-portrait");

    const mediaMarkup = preview.provider === "instagram"
      ? this.instagramPreviewMarkup(preview)
      : preview.provider === "tiktok"
        ? this.tiktokPreviewMarkup(preview)
        : `<iframe src="${this.escapeAttribute(preview.embedUrl)}" title="${this.escapeAttribute(providerLabel)}" class="raw-footage-preview-media" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen></iframe>`;

    const shellMarkup = preview.provider === "instagram" || preview.provider === "tiktok"
      ? `<div class="raw-footage-social-preview">${mediaMarkup}</div>`
      : `<div class="rounded-3 overflow-hidden bg-dark ${shellClasses.join(" ")}" style="aspect-ratio: ${this.escapeAttribute(preview.aspectRatio || "16 / 9")};">${mediaMarkup}</div>`;

    this.rawFootagePreviewTarget.innerHTML = `
      <div class="card border-0 shadow-sm raw-footage-preview-card">
        <div class="card-body">
          <div class="d-flex justify-content-between align-items-center gap-3 mb-3">
            <div>
              <p class="text-uppercase text-body-secondary small mb-1">Live preview</p>
              <h3 class="h6 mb-0">${this.escapeHtml(providerLabel)}</h3>
            </div>
            <span class="badge text-bg-primary">Recognized</span>
          </div>
          ${shellMarkup}
        </div>
      </div>
    `;
    if (preview.provider === "instagram" || preview.provider === "tiktok") {
      this.loadSocialEmbedScript(preview.provider);
    }
    this.rawFootagePreviewTarget.classList.add("is-visible");
  }

  parseRawFootageUrl(value) {
    const url = this.normalizeUrl(value);
    if (!url || url.protocol !== "https:") return null;

    const youtube = this.parseYouTubeUrl(url);
    if (youtube) return youtube;

    const instagram = this.parseInstagramUrl(url);
    if (instagram) return instagram;

    const tiktok = this.parseTiktokUrl(url);
    if (tiktok) return tiktok;

    const twitch = this.parseTwitchUrl(url);
    if (twitch) return twitch;

    return this.parseVimeoUrl(url);
  }

  parseYouTubeUrl(url) {
    const host = url.host.toLowerCase();
    const hosts = ["youtube.com", "www.youtube.com", "m.youtube.com", "youtu.be", "www.youtu.be"];
    if (!hosts.includes(host)) return null;

    let videoId = null;
    if (host === "youtu.be" || host === "www.youtu.be") {
      videoId = url.pathname.split("/").filter(Boolean)[0] || null;
    } else {
      const params = new URLSearchParams(url.search);
      videoId = params.get("v");
      if (!videoId) {
        const segments = url.pathname.split("/").filter(Boolean);
        if (segments[0] === "embed" || segments[0] === "shorts") videoId = segments[1] || null;
      }
    }

    if (!videoId) return null;

    return {
      provider: "youtube",
      videoId,
      aspectRatio: host === "www.youtube.com" || host === "youtube.com" || host === "m.youtube.com"
        ? (url.pathname.split("/").filter(Boolean)[0] === "shorts" ? "9 / 16" : "16 / 9")
        : "16 / 9",
      embedUrl: `https://www.youtube-nocookie.com/embed/${videoId}`,
      thumbnailUrl: `https://img.youtube.com/vi/${videoId}/hqdefault.jpg`,
      watchUrl: `https://www.youtube.com/watch?v=${videoId}`,
    };
  }

  parseVimeoUrl(url) {
    const host = url.host.toLowerCase();
    const hosts = ["vimeo.com", "www.vimeo.com", "player.vimeo.com"];
    if (!hosts.includes(host)) return null;

    const segments = url.pathname.split("/").filter(Boolean);
    const videoId =
      host === "player.vimeo.com" && segments[0] === "video"
        ? segments[1]
        : [...segments].reverse().find((segment) => /^\d+$/.test(segment));

    if (!videoId) return null;

    return {
      provider: "vimeo",
      videoId,
      aspectRatio: "16 / 9",
      embedUrl: `https://player.vimeo.com/video/${videoId}`,
      watchUrl: `https://vimeo.com/${videoId}`,
    };
  }

  parseInstagramUrl(url) {
    const host = url.host.toLowerCase();
    const hosts = ["instagram.com", "www.instagram.com", "instagr.am", "www.instagr.am"];
    if (!hosts.includes(host)) return null;

    const segments = url.pathname.split("/").filter(Boolean);
    if (!["p", "reel", "reels", "tv"].includes(segments[0])) return null;

    const postId = segments[1];
    if (!postId) return null;

    return {
      provider: "instagram",
      videoId: postId,
      aspectRatio: "4 / 5",
      watchUrl: url.toString(),
      permalink: url.toString(),
    };
  }

  parseTiktokUrl(url) {
    const host = url.host.toLowerCase();
    const hosts = ["tiktok.com", "www.tiktok.com", "m.tiktok.com"];
    if (!hosts.includes(host)) return null;

    const segments = url.pathname.split("/").filter(Boolean);
    const videoId =
      segments[0]?.startsWith("@") && segments[1] === "video"
        ? segments[2]
        : segments.find((segment) => /^\d+$/.test(segment));

    if (!videoId) return null;

    return {
      provider: "tiktok",
      videoId,
      aspectRatio: "9 / 16",
      watchUrl: url.toString(),
      permalink: url.toString(),
    };
  }

  parseTwitchUrl(url) {
    const host = url.host.toLowerCase();
    const hosts = ["twitch.tv", "www.twitch.tv", "player.twitch.tv"];
    if (!hosts.includes(host)) return null;

    const segments = url.pathname.split("/").filter(Boolean);
    const videoId =
      segments[0] === "videos" && segments[1]
        ? segments[1]
        : segments.find((segment) => /^\d+$/.test(segment));

    if (!videoId) return null;

    return {
      provider: "twitch",
      videoId,
      aspectRatio: "16 / 9",
      embedUrl: `https://player.twitch.tv/?video=v${videoId}&parent=${window.location.hostname}`,
      watchUrl: `https://www.twitch.tv/videos/${videoId}`,
    };
  }

  instagramPreviewMarkup(preview) {
    return `
      <blockquote
        class="instagram-media raw-footage-social-embed"
        data-instgrm-captioned=""
        data-instgrm-permalink="${this.escapeAttribute(preview.permalink || preview.watchUrl)}"
        data-instgrm-version="14"
        style="background:#FFF; border:0; margin:0 auto; max-width:540px; min-width:326px; padding:0; width:99.375%;"
      >
        <a href="${this.escapeAttribute(preview.permalink || preview.watchUrl)}" target="_blank" rel="noopener">${this.escapeHtml("Open Instagram post")}</a>
      </blockquote>
    `;
  }

  tiktokPreviewMarkup(preview) {
    return `
      <blockquote
        class="tiktok-embed raw-footage-social-embed"
        cite="${this.escapeAttribute(preview.permalink || preview.watchUrl)}"
        data-video-id="${this.escapeAttribute(preview.videoId)}"
        style="max-width:605px; min-width:325px; margin:0 auto;"
      >
        <section>
          <a href="${this.escapeAttribute(preview.permalink || preview.watchUrl)}" target="_blank" rel="noopener">${this.escapeHtml("Open TikTok video")}</a>
        </section>
      </blockquote>
    `;
  }

  loadSocialEmbedScript(provider) {
    const scripts = {
      instagram: "https://www.instagram.com/embed.js",
      tiktok: "https://www.tiktok.com/embed.js",
    };
    const ids = {
      instagram: "raw-footage-instagram-embed-script",
      tiktok: "raw-footage-tiktok-embed-script",
    };
    const callbacks = {
      instagram: () => window.instgrm?.Embeds?.process?.(),
      tiktok: () => {
        const embeds = this.rawFootagePreviewTarget.querySelectorAll("blockquote.tiktok-embed");
        window.tiktokEmbed?.lib?.render?.(embeds);
      },
    };

    this.appendSocialScript(ids[provider], scripts[provider], callbacks[provider]);
  }

  appendSocialScript(id, src, onload) {
    const existing = document.getElementById(id);
    if (existing) existing.remove();

    const script = document.createElement("script");
    script.id = id;
    script.async = true;
    script.defer = true;
    script.src = src;
    if (onload) script.addEventListener("load", onload, { once: true });
    document.body.appendChild(script);
  }

  normalizeUrl(value) {
    const raw = (value || "").trim();
    if (!raw) return null;

    const normalized = raw.match(/^https?:\/\//i) ? raw : `https://${raw}`;

    try {
      return new URL(normalized);
    } catch {
      return null;
    }
  }

  escapeAttribute(value) {
    return this.escapeHtml(value).replace(/"/g, "&quot;");
  }

  escapeHtml(value) {
    const div = document.createElement("div");
    div.textContent = value;
    return div.innerHTML;
  }
}
