import "bootstrap/dist/css/bootstrap.min.css"
import "bootstrap/dist/js/bootstrap.bundle.min.js"
import $ from "jquery"
import { Application } from "@hotwired/stimulus"
import consumer from "../channels/consumer"
import { subscribeToClientNotifications, subscribeToPMNotifications } from "../channels/notifications_channel"
import { subscribeToProjectComments } from "../channels/project_comments_channel"
import { subscribeToProjectStatus } from "../channels/project_status_channel"
import "./application.css"
import PMProjectActionController from "../controllers/pm_project_action_controller"
import RoleSwitchController from "../controllers/role_switch_controller"
import NotificationActionController from "../controllers/notification_action_controller"
import CommentFormController from "../controllers/comment_form_controller"
import OrderFormController from "../controllers/order_form_controller"
import SecretRevealController from "../controllers/secret_reveal_controller"

globalThis.$ = $
globalThis.jQuery = $

const application = Application.start()
application.register("order-form", OrderFormController)
application.register("role-switch", RoleSwitchController)
application.register("notification-action", NotificationActionController)
application.register("comment-form", CommentFormController)
application.register("pm-project-action", PMProjectActionController)
application.register("secret-reveal", SecretRevealController)

subscribeToPMNotifications(consumer)
subscribeToClientNotifications(consumer)
subscribeToProjectComments(consumer)
subscribeToProjectStatus(consumer)

console.log("Vite Rails is ready")
