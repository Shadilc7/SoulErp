import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Auto-hide flash messages after 5 seconds
    setTimeout(() => {
      this.element.remove()
    }, 5000)
  }
} 