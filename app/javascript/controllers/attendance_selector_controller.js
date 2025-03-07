import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "actions", "noSelection", "programTitle", "markBtn", "editBtn", "historyBtn", "dateSelector", "dateContainer"]

  connect() {
    console.log("Attendance selector controller connected")
    this.updateUI()
  }

  toggleCompletedPrograms(event) {
    const showCompleted = event.target.checked
    const select = this.selectTarget
    
    // Loop through all options and show/hide completed programs
    Array.from(select.options).forEach(option => {
      if (option.value && option.dataset.status === 'completed') {
        option.style.display = showCompleted ? '' : 'none'
        option.disabled = !showCompleted
      }
    })
  }

  updateUI() {
    const select = this.selectTarget
    const selectedOption = select.options[select.selectedIndex]
    
    if (select.value) {
      // Show actions and hide no selection message
      this.actionsTarget.classList.remove('d-none')
      if (this.hasNoSelectionTarget) {
        this.noSelectionTarget.classList.add('d-none')
      }
      
      // Update program title
      if (this.hasProgramTitleTarget) {
        this.programTitleTarget.textContent = selectedOption.textContent.trim()
      }
      
      // Update buttons with URLs from data attributes
      if (selectedOption.dataset.status === 'completed') {
        this.markBtnTarget.classList.add('d-none')
      } else {
        this.markBtnTarget.classList.remove('d-none')
        this.markBtnTarget.href = selectedOption.dataset.markUrl
      }
      this.historyBtnTarget.href = selectedOption.dataset.historyUrl
      
      // Show date selector if we have one
      if (this.hasDateContainerTarget) {
        this.dateContainerTarget.classList.remove('d-none')
        
        // Set min and max dates based on program dates
        if (this.hasDateSelectorTarget) {
          const startDate = selectedOption.dataset.startDate
          const endDate = selectedOption.dataset.endDate
          
          if (startDate && endDate) {
            this.dateSelectorTarget.min = startDate
            this.dateSelectorTarget.max = endDate
            
            // Set default date to today if within range, otherwise to start date
            const today = new Date().toISOString().split('T')[0]
            if (today >= startDate && today <= endDate) {
              this.dateSelectorTarget.value = today
            } else {
              this.dateSelectorTarget.value = startDate
            }
            
            // Update buttons with the selected date
            this.updateButtonsWithDate()
          }
        }
      }
    } else {
      // Hide actions and show no selection message
      this.actionsTarget.classList.add('d-none')
      if (this.hasNoSelectionTarget) {
        this.noSelectionTarget.classList.remove('d-none')
      }
      
      // Hide date selector
      if (this.hasDateContainerTarget) {
        this.dateContainerTarget.classList.add('d-none')
      }
    }
  }
  
  updateButtonsWithDate() {
    const select = this.selectTarget
    const selectedOption = select.options[select.selectedIndex]
    
    if (!select.value) return
    
    let dateParam = ""
    if (this.hasDateSelectorTarget && this.dateSelectorTarget.value) {
      dateParam = `?date=${this.dateSelectorTarget.value}`
    }
    
    // Update mark button URL with the selected date
    const baseMarkUrl = selectedOption.dataset.markUrl.split('?')[0]
    this.markBtnTarget.href = `${baseMarkUrl}${dateParam}`
    
    // Update history button URL
    this.historyBtnTarget.href = selectedOption.dataset.historyUrl
    
    // Check if attendance is already marked for the selected date
    this.checkAttendanceStatus()
  }
  
  checkAttendanceStatus() {
    if (!this.hasDateSelectorTarget || !this.selectTarget.value) return
    
    const programId = this.selectTarget.value
    const date = this.dateSelectorTarget.value
    
    console.log(`Checking attendance status for program ${programId} on ${date}`)
    
    // Determine the correct path based on the current URL
    let checkPath = window.location.pathname.includes('institute_admin') 
      ? `/institute_admin/attendances/${programId}/check_status` 
      : `/trainer_portal/attendances/${programId}/check_status`
    
    console.log(`Check path: ${checkPath}?date=${date}`)
    
    fetch(`${checkPath}?date=${date}`, {
      headers: {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
      .then(response => {
        console.log("Response status:", response.status)
        return response.json()
      })
      .then(data => {
        console.log("Attendance status data:", data)
        
        // Make sure we have the edit button target
        if (!this.hasEditBtnTarget) {
          console.error("Edit button target not found")
          return
        }
        
        if (data.marked) {
          console.log("Attendance is marked, showing edit button")
          // Attendance is marked, show edit button and hide mark button
          this.editBtnTarget.href = data.edit_url
          this.editBtnTarget.classList.remove('d-none')
          this.markBtnTarget.innerHTML = '<i class="bi bi-check-circle me-1"></i> Attendance Already Marked'
          this.markBtnTarget.classList.add('disabled')
          this.markBtnTarget.classList.remove('btn-primary')
          this.markBtnTarget.classList.add('btn-secondary')
        } else {
          console.log("Attendance is not marked, hiding edit button")
          // Attendance is not marked, show mark button and hide edit button
          this.editBtnTarget.classList.add('d-none')
          this.markBtnTarget.innerHTML = '<i class="bi bi-plus-circle me-1"></i> Mark Attendance'
          this.markBtnTarget.classList.remove('disabled')
          this.markBtnTarget.classList.add('btn-primary')
          this.markBtnTarget.classList.remove('btn-secondary')
        }
      })
      .catch(error => {
        console.error("Error checking attendance status:", error)
      })
  }
  
  dateChanged() {
    this.updateButtonsWithDate()
  }
  
  change(event) {
    this.updateUI()
  }
}