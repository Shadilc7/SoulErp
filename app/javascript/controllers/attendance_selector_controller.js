import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "actions", "noSelection", "programTitle", "markBtn", "editBtn", "historyBtn", "dateSelector", "dateContainer"]

  connect() {
    console.log("Attendance selector controller connected")
    this.updateUI()
  }

  updateUI() {
    const select = this.selectTarget
    const selectedOption = select.options[select.selectedIndex]
    
    if (select.value) {
      // Show actions and hide no selection message
      this.actionsTarget.classList.remove('d-none')
      this.noSelectionTarget.classList.add('d-none')
      
      // Update program title
      this.programTitleTarget.textContent = selectedOption.textContent
      
      // Show date selector
      if (this.hasDateContainerTarget) {
        this.dateContainerTarget.classList.remove('d-none')
        
        // Set min and max dates for the date picker
        if (this.hasDateSelectorTarget) {
          const startDate = selectedOption.dataset.startDate
          const endDate = selectedOption.dataset.endDate
          
          this.dateSelectorTarget.min = startDate
          this.dateSelectorTarget.max = endDate
          
          // Set default to today if within range, otherwise to end date
          const today = new Date().toISOString().split('T')[0]
          
          if (today >= startDate && today <= endDate) {
            // Today is within the program duration, use today
            this.dateSelectorTarget.value = today
          } else if (today > endDate) {
            // Today is after the program end date, use end date
            this.dateSelectorTarget.value = endDate
          } else {
            // Today is before the program start date, use start date
            this.dateSelectorTarget.value = startDate
          }
          
          // Update buttons with the selected date
          this.updateButtonsWithDate()
        }
      }
      
      // Initial button setup
      this.updateButtonsWithDate()
    } else {
      // Hide actions and show no selection message
      this.actionsTarget.classList.add('d-none')
      this.noSelectionTarget.classList.remove('d-none')
      
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
    
    fetch(`/institute_admin/attendances/${programId}/check_status?date=${date}`)
      .then(response => response.json())
      .then(data => {
        if (data.marked) {
          // Attendance is marked, show edit button and hide mark button
          this.editBtnTarget.href = data.edit_url
          this.editBtnTarget.classList.remove('d-none')
          this.markBtnTarget.textContent = "Attendance Already Marked"
          this.markBtnTarget.classList.add('disabled')
        } else {
          // Attendance is not marked, show mark button and hide edit button
          this.editBtnTarget.classList.add('d-none')
          this.markBtnTarget.textContent = "Mark Attendance"
          this.markBtnTarget.classList.remove('disabled')
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