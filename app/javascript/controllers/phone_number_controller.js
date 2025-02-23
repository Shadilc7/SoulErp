import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener('input', this.handleInput.bind(this))
  }

  handleInput(event) {
    // Remove any non-digit characters
    let value = event.target.value.replace(/[^0-9]/g, '')
    
    // Limit to 10 digits
    if (value.length > 10) {
      value = value.slice(0, 10)
    }
    
    // Update input value
    event.target.value = value
  }
} 