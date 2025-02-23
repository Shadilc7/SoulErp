import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "instituteSelect", "sectionSelect" ]

  connect() {
    // Initialize with empty sections
    this.updateSections([])
  }

  fetchSections() {
    const instituteId = this.instituteSelectTarget.value
    if (!instituteId) {
      this.updateSections([])
      return
    }

    fetch(`/sections/fetch?institute_id=${instituteId}`)
      .then(response => response.json())
      .then(sections => {
        this.updateSections(sections)
      })
      .catch(error => {
        console.error("Error fetching sections:", error)
        this.updateSections([])
      })
  }

  updateSections(sections) {
    const options = [
      `<option value="">Select Section</option>`
    ]
    
    sections.forEach(section => {
      options.push(`<option value="${section.id}">${section.name}</option>`)
    })
    
    this.sectionSelectTarget.innerHTML = options.join('')
  }
} 