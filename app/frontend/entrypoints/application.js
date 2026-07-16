import "bootstrap/dist/css/bootstrap.min.css"
import "bootstrap/dist/js/bootstrap.bundle.min.js"
import $ from "jquery"
import { Application } from "@hotwired/stimulus"
import "./application.css"
import OrderFormController from "../controllers/order_form_controller"

globalThis.$ = $
globalThis.jQuery = $

const application = Application.start()
application.register("order-form", OrderFormController)

console.log("Vite Rails is ready")
