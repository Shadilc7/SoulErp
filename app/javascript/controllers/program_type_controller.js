import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "sectionField", "participantField", "select" ]

  connect() {
    this.toggle()
    this.setupEventListener()
  }

  setupEventListener() {
    const select = document.getElementById('training_program_program_type')
    if (select) {
      select.addEventListener('change', () => this.toggle())
    }
  }

  toggle() {
    const programType = this.selectTarget.value
    
    if (programType === "individual") {
      this.sectionFieldTarget.style.display = "none"
      this.participantFieldTarget.style.display = "block"
    } else if (programType === "section") {
      this.sectionFieldTarget.style.display = "block"
      this.participantFieldTarget.style.display = "none"
    } else {
      this.sectionFieldTarget.style.display = "none"
      this.participantFieldTarget.style.display = "none"
    }
  }

  toggleAllParticipants(event) {
    const isChecked = event.target.checked
    const checkboxes = document.querySelectorAll('.participant-checkbox')
    
    checkboxes.forEach(checkbox => {
      checkbox.checked = isChecked
    })
  }

  toggleAllSections(event) {
    const isChecked = event.target.checked
    const checkboxes = document.querySelectorAll('.section-checkbox')
    
    checkboxes.forEach(checkbox => {
      checkbox.checked = isChecked
    })
  }
} 