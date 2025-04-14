import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="participant-select"
export default class extends Controller {
  static targets = ["section", "participant"]
  
  connect() {
    console.log("ParticipantSelect controller connected")
    
    // If a section is already selected, load its participants
    if (this.sectionTarget.value) {
      this.loadParticipants(this.sectionTarget.value)
    }
  }
  
  sectionChanged() {
    const sectionId = this.sectionTarget.value
    this.loadParticipants(sectionId)
  }
  
  loadParticipants(sectionId) {
    if (!sectionId) {
      this.participantTarget.disabled = true
      this.participantTarget.innerHTML = '<option value="">First select a section</option>'
      return
    }
    
    // Show loading state
    this.participantTarget.disabled = true
    this.participantTarget.innerHTML = '<option value="">Loading participants...</option>'
    
    // Add a timestamp to prevent caching
    const timestamp = new Date().getTime()
    const url = `/institute_admin/sections/${sectionId}/participants?_=${timestamp}`
    
    fetch(url)
      .then(response => {
        if (!response.ok) {
          throw new Error(`Failed to load participants: ${response.status} ${response.statusText}`)
        }
        return response.json()
      })
      .then(data => {
        // Enable the dropdown and add the prompt
        this.participantTarget.disabled = false
        this.participantTarget.innerHTML = '<option value="">Choose a participant</option>'
        
        if (data && data.length > 0) {
          // Add participants to the dropdown
          data.forEach(participant => {
            const option = document.createElement('option')
            option.value = participant.id
            option.textContent = participant.full_name
            this.participantTarget.appendChild(option)
          })
          
          // If participant was previously selected, try to re-select it
          const urlParams = new URLSearchParams(window.location.search)
          const urlParticipantId = urlParams.get('participant_id')
          if (urlParticipantId) {
            const option = this.participantTarget.querySelector(`option[value="${urlParticipantId}"]`)
            if (option) {
              option.selected = true
            }
          }
        } else {
          this.participantTarget.innerHTML = '<option value="">No participants found</option>'
          this.participantTarget.disabled = true
        }
      })
      .catch(error => {
        console.error('Error loading participants:', error)
        this.participantTarget.innerHTML = '<option value="">Error loading participants</option>'
        this.participantTarget.disabled = true
      })
  }
} 