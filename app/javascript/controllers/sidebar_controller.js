// Sidebar controller for collapsible navigation
// Handles toggle state persistence in localStorage and mobile drawer behavior

export default class extends Controller {
  static targets = ["sidebar", "toggleButton", "navLink"];

  static values = {
    collapsed: Boolean,
    mobileOpen: Boolean,
  };

  connect() {
    this.loadState();
    this.applyState();
    this.setupEventListeners();
  }

  disconnect() {
    this.removeEventListeners();
  }

  loadState() {
    const stored = localStorage.getItem("sidebar:collapsed");
    this.collapsedValue = stored === "true";

    // On mobile, default to closed (not open)
    this.mobileOpenValue = false;
  }

  saveState() {
    localStorage.setItem("sidebar:collapsed", this.collapsedValue.toString());
  }

  applyState() {
    if (this.isMobile) {
      this.sidebarTarget.classList.toggle("open", this.mobileOpenValue);
      document.body.classList.toggle("sidebar-open", this.mobileOpenValue);
    } else {
      this.sidebarTarget.classList.toggle("collapsed", this.collapsedValue);
      this.toggleButtonTarget.setAttribute("aria-expanded", (!this.collapsedValue).toString());
    }
  }

  get isMobile() {
    return window.matchMedia("(max-width: 768px)").matches;
  }

  setupEventListeners() {
    // Handle window resize for responsive behavior
    this.resizeHandler = () => this.handleResize();
    window.addEventListener("resize", this.resizeHandler);

    // Close mobile drawer on escape key
    this.keydownHandler = (e) => {
      if (e.key === "Escape" && this.isMobile && this.mobileOpenValue) {
        this.close();
      }
    };
    document.addEventListener("keydown", this.keydownHandler);
  }

  removeEventListeners() {
    window.removeEventListener("resize", this.resizeHandler);
    document.removeEventListener("keydown", this.keydownHandler);
  }

  handleResize() {
    const wasMobile = this.mobileOpenValue || this.sidebarTarget.classList.contains("open");
    const nowMobile = this.isMobile;

    if (wasMobile && !nowMobile) {
      // Transitioning from mobile to desktop
      this.mobileOpenValue = false;
      this.sidebarTarget.classList.remove("open");
      document.body.classList.remove("sidebar-open");
      this.applyState();
    } else if (!wasMobile && nowMobile) {
      // Transitioning from desktop to mobile
      this.collapsedValue = false;
      this.sidebarTarget.classList.remove("collapsed");
      this.applyState();
    }
  }

  toggle() {
    if (this.isMobile) {
      this.mobileOpenValue = !this.mobileOpenValue;
    } else {
      this.collapsedValue = !this.collapsedValue;
      this.saveState();
    }
    this.applyState();
  }

  close() {
    if (this.isMobile) {
      this.mobileOpenValue = false;
      this.applyState();
    }
  }

  // Called when a nav link is clicked on mobile - close the drawer
  navigate() {
    if (this.isMobile) {
      this.close();
    }
  }
}