import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "content" ]
  static values = { 
    url: String 
  }

  connect() {
    console.log("Assignment date controller connected")
  }

  fetchAssignment(event) {
    const selectedDate = event.target.value
    const url = `/participant_portal/assignments?date=${selectedDate}`
    
    fetch(url, {
      headers: {
        "Accept": "text/vnd.turbo-stream.html",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      credentials: 'same-origin'
    })
    .then(response => {
      if (!response.ok) {
        throw new Error('Network response was not ok')
      }
      return response.text()
    })
    .then(html => {
      Turbo.renderStreamMessage(html)
    })
    .catch(error => {
      console.error('Error:', error)
      // Optionally show an error message to the user
    })
  }
} 