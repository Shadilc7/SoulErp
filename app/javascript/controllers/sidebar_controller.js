import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "backdrop"]

  connect() {
    // Handle initial mobile state
    this.checkMobileState()
    
    // Listen for window resize
    window.addEventListener('resize', this.checkMobileState.bind(this))
  }

  toggle() {
    this.contentTarget.classList.toggle('show')
    this.backdropTarget.classList.toggle('show')
    document.body.style.overflow = this.contentTarget.classList.contains('show') ? 'hidden' : ''
  }

  hide() {
    this.contentTarget.classList.remove('show')
    this.backdropTarget.classList.remove('show')
    document.body.style.overflow = ''
  }

  checkMobileState() {
    if (window.innerWidth >= 768) {
      this.hide()
    }
  }

  disconnect() {
    window.removeEventListener('resize', this.checkMobileState.bind(this))
  }
} 