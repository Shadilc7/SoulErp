import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dateInput", "content"]
  static values = { 
    url: String 
  }

  connect() {
    console.log("Assignment date controller connected")
    // Initialize button state on connect
    console.log("Initial date value:", this.dateInputTarget.value)
    this.updateNextButtonState(this.dateInputTarget.value)
  }

  fetchAssignment(event) {
    const selectedDate = event.target.value
    console.log("Date changed to:", selectedDate)
    this.fetchAssignmentForDate(selectedDate)
    // Update button state when date is changed manually
    this.updateNextButtonState(selectedDate)
  }
  
  previousDay(event) {
    event.preventDefault()
    
    // Get current date from input
    const currentDate = new Date(this.dateInputTarget.value)
    console.log("Previous day from:", this.dateInputTarget.value)
    
    // Subtract one day
    currentDate.setDate(currentDate.getDate() - 1)
    
    // Format date as YYYY-MM-DD
    const previousDate = this.formatDate(currentDate)
    console.log("Going to previous day:", previousDate)
    
    // Update the date input
    this.dateInputTarget.value = previousDate
    
    // Fetch assignments for the new date
    this.fetchAssignmentForDate(previousDate)
    
    // Update the next button's disabled state after going to previous day
    this.updateNextButtonState(previousDate)
  }
  
  nextDay(event) {
    event.preventDefault()
    console.log("Next day button clicked")
    
    // Get current date from input
    const currentDate = new Date(this.dateInputTarget.value)
    console.log("Next day from:", this.dateInputTarget.value)
    
    // Add one day
    currentDate.setDate(currentDate.getDate() + 1)
    
    // Get today's date
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    console.log("Today is:", this.formatDate(today))
    
    // Compare dates as strings to avoid time zone issues
    const nextDateStr = this.formatDate(currentDate)
    const todayStr = this.formatDate(today)
    
    console.log("Next date string:", nextDateStr)
    console.log("Today string:", todayStr)
    console.log("Is next date > today:", nextDateStr > todayStr)
    
    // Check if the next day is in the future
    if (nextDateStr > todayStr) {
      console.log("Cannot go beyond today")
      return // Don't go beyond today
    }
    
    // Format date as YYYY-MM-DD
    const nextDate = this.formatDate(currentDate)
    console.log("Going to next day:", nextDate)
    
    // Update the date input
    this.dateInputTarget.value = nextDate
    
    // Fetch assignments for the new date
    this.fetchAssignmentForDate(nextDate)
    
    // Update the next button's disabled state
    this.updateNextButtonState(nextDate)
  }
  
  fetchAssignmentForDate(date) {
    const url = `/participant_portal/assignments?date=${date}`
    console.log("Fetching assignments for date:", date)
    
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
  
  formatDate(date) {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
  }
  
  updateNextButtonState(date) {
    // Find all next day buttons on the page
    const nextButtons = document.querySelectorAll('[data-action*="assignment-date#nextDay"]')
    
    // Get today's date
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    
    // Parse the current date
    const currentDate = new Date(date)
    currentDate.setHours(0, 0, 0, 0)
    
    console.log("Updating button state:")
    console.log("- Current date:", this.formatDate(currentDate))
    console.log("- Today:", this.formatDate(today))
    
    // Compare dates as strings to avoid time zone issues
    const currentDateStr = this.formatDate(currentDate)
    const todayStr = this.formatDate(today)
    
    console.log("- Current date string:", currentDateStr)
    console.log("- Today string:", todayStr)
    console.log("- Should disable if current > today:", currentDateStr > todayStr)
    console.log("- Should disable if current = today:", currentDateStr === todayStr)
    
    // Disable the button if:
    // 1. The current date is greater than today (future date)
    // 2. The current date is equal to today (can't go beyond today)
    const shouldDisable = currentDateStr >= todayStr
    console.log("- Final decision - button disabled:", shouldDisable)
    
    nextButtons.forEach(button => {
      button.disabled = shouldDisable
    })
  }
} 