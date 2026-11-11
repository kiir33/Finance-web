// Auth form controller — password visibility toggle and submit state.
export default class extends Controller {
  static targets = ["password", "submit"];

  connect() {
    this.passwordInput = this.passwordTarget;
    this.showing = false;
  }

  togglePassword(event) {
    const button = event.currentTarget;
    const icon = button.querySelector("svg");
    this.showing = !this.showing;

    if (this.showing) {
      this.passwordInput.type = "text";
      button.setAttribute("aria-pressed", "true");
      button.setAttribute("aria-label", "Hide password");
    } else {
      this.passwordInput.type = "password";
      button.setAttribute("aria-pressed", "false");
      button.setAttribute("aria-label", "Show password");
    }
  }

  // Called via data- on the submit button; disables the button while the
  // form is being submitted to prevent double-submits.
  disableSubmit() {
    this.submitTarget.disabled = true;
    this.submitTarget.classList.add("opacity-50", "cursor-not-allowed");
  }
}
