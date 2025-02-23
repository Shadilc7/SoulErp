import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropdown"]

  connect() {
    // Close dropdown when clicking outside
    document.addEventListener('click', this.handleClickOutside.bind(this))
  }

  disconnect() {
    document.removeEventListener('click', this.handleClickOutside.bind(this))
  }

  toggle(event) {
    event.stopPropagation()
    this.dropdownTarget.classList.toggle('d-none')
  }

  select(event) {
    const option = event.currentTarget
    const type = option.dataset.type
    const icon = option.querySelector('.bi').className
    
    // Update header
    const header = this.element.querySelector('.selected-type')
    header.querySelector('.type-icon i').className = icon
    header.querySelector('.type-text').textContent = type.replace(/_/g, ' ').titleize()
    
    // Update radio button
    const radio = option.querySelector('input[type="radio"]')
    radio.checked = true
    
    // Update active state
    this.element.querySelectorAll('.type-option').forEach(opt => {
      opt.classList.toggle('active', opt === option)
    })
    
    // Close dropdown
    this.dropdownTarget.classList.add('d-none')
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.dropdownTarget.classList.add('d-none')
    }
  }
} 