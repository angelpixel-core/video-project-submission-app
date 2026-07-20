import "bootstrap/dist/css/bootstrap.min.css"
import "bootstrap/dist/js/bootstrap.bundle.min.js"
import $ from "jquery"
import { Application } from "@hotwired/stimulus"
import consumer from "../channels/consumer"
import { subscribeToPMNotifications } from "../channels/pm_notification_channel"
import "./application.css"
import RoleSwitchController from "../controllers/role_switch_controller"
import NotificationActionController from "../controllers/notification_action_controller"
import OrderFormController from "../controllers/order_form_controller"
import SecretRevealController from "../controllers/secret_reveal_controller"

globalThis.$ = $
globalThis.jQuery = $

const application = Application.start()
application.register("order-form", OrderFormController)
application.register("role-switch", RoleSwitchController)
application.register("notification-action", NotificationActionController)
application.register("secret-reveal", SecretRevealController)

subscribeToPMNotifications(consumer)

console.log("Vite Rails is ready")
