// Stimulus controllers index
import { application } from "./application"

// Import and register controllers
import SidebarController from "./sidebar_controller"
import AuthFormController from "./auth_form_controller"
application.register("sidebar", SidebarController)
application.register("auth-form", AuthFormController)