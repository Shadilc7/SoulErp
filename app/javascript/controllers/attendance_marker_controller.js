import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["row", "statusRadio"]

  connect() {
    console.log("Attendance marker controller connected")
    this.setupEventListeners()
  }

  setupEventListeners() {
    // Add event listeners for status changes to update row styling
    if (this.hasStatusRadioTarget) {
      this.statusRadioTargets.forEach(radio => {
        radio.addEventListener('change', (event) => {
          this.updateRowStatus(event.target)
        })
      })
    }
  }

  markAllPresent() {
    this.markAllWithStatus('present')
  }

  markAllAbsent() {
    this.markAllWithStatus('absent')
  }

  markAllLate() {
    this.markAllWithStatus('late')
  }

  markAllWithStatus(status) {
    const rows = document.querySelectorAll('tr[data-participant-id]')
    rows.forEach(row => {
      const participantId = row.dataset.participantId
      const statusRadio = document.querySelector(`input[name="attendance[attendances][${participantId}]"][value="${status}"]`)
      
      if (statusRadio) {
        statusRadio.checked = true
        this.updateRowStatus(statusRadio)
      }
    })
  }

  updateRowStatus(radio) {
    if (!radio.checked) return

    const participantId = radio.name.match(/\[(\d+)\]/)[1]
    const row = document.querySelector(`tr[data-participant-id="${participantId}"]`)
    
    if (row) {
      // Remove all status classes
      row.classList.remove('present-row', 'absent-row', 'late-row')
      // Add the new status class
      row.classList.add(`${radio.value}-row`)
    }
  }
} 