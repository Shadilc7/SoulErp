import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Attendance marker controller connected")
    this.updateAllRowHighlights()
  }

  updateRowHighlight(event) {
    const radio = event.target
    const row = radio.closest('.attendance-row')
    
    // Remove all status classes
    row.classList.remove('present-row', 'absent-row', 'late-row')
    
    // Add the appropriate class based on the selected status
    if (radio.value === 'present') {
      row.classList.add('present-row')
    } else if (radio.value === 'absent') {
      row.classList.add('absent-row')
    } else if (radio.value === 'late') {
      row.classList.add('late-row')
    }
  }
  
  updateAllRowHighlights() {
    // Get all rows
    const rows = document.querySelectorAll('.attendance-row')
    
    // For each row, find the checked radio and update the highlight
    rows.forEach(row => {
      const checkedRadio = row.querySelector('input[type="radio"]:checked')
      if (checkedRadio) {
        row.classList.remove('present-row', 'absent-row', 'late-row')
        
        if (checkedRadio.value === 'present') {
          row.classList.add('present-row')
        } else if (checkedRadio.value === 'absent') {
          row.classList.add('absent-row')
        } else if (checkedRadio.value === 'late') {
          row.classList.add('late-row')
        }
      }
    })
  }
  
  markAllPresent() {
    const rows = document.querySelectorAll('.attendance-row')
    
    rows.forEach(row => {
      const participantId = row.dataset.participantId
      const presentRadio = document.getElementById(`present_${participantId}`)
      
      if (presentRadio) {
        presentRadio.checked = true
        row.classList.remove('present-row', 'absent-row', 'late-row')
        row.classList.add('present-row')
      }
    })
  }
  
  markAllAbsent() {
    const rows = document.querySelectorAll('.attendance-row')
    
    rows.forEach(row => {
      const participantId = row.dataset.participantId
      const absentRadio = document.getElementById(`absent_${participantId}`)
      
      if (absentRadio) {
        absentRadio.checked = true
        row.classList.remove('present-row', 'absent-row', 'late-row')
        row.classList.add('absent-row')
      }
    })
  }
} 