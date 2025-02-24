import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["backdrop", "content"]

  connect() {
    // Handle initial mobile state
    this.checkMobileState()
    
    // Listen for window resize
    window.addEventListener('resize', () => this.checkMobileState())
  }

  toggle() {
    this.element.classList.toggle('show')
    this.backdropTarget.classList.toggle('show')
    document.body.style.overflow = this.element.classList.contains('show') ? 'hidden' : ''
  }

  hide() {
    this.element.classList.remove('show')
    this.backdropTarget.classList.remove('show')
    document.body.style.overflow = ''
  }

  checkMobileState() {
    if (window.innerWidth >= 992) {
      this.hide()
    }
  }

  disconnect() {
    window.removeEventListener('resize', () => this.checkMobileState())
  }
} 