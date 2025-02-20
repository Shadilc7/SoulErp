import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "sectionField", "participantField" ]

  connect() {
    this.toggleFields()
    this.setupEventListener()
  }

  setupEventListener() {
    const select = document.getElementById('training_program_program_type')
    if (select) {
      select.addEventListener('change', () => this.toggleFields())
    }
  }

  toggleFields() {
    const programType = document.getElementById('training_program_program_type').value
    
    if (programType === 'individual') {
      this.sectionFieldTarget.style.display = 'none'
      this.participantFieldTarget.style.display = 'block'
    } else {
      this.sectionFieldTarget.style.display = 'block'
      this.participantFieldTarget.style.display = 'none'
    }
  }
} 