import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Program filter controller connected")
  }
  
  toggleCompleted(event) {
    const showCompleted = event.target.checked
    const completedRows = document.querySelectorAll('tr.table-secondary')
    
    completedRows.forEach(row => {
      row.style.display = showCompleted ? '' : 'none'
    })
  }
} 