import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "actions", "noSelection", "programTitle", "markBtn", "editBtn", "historyBtn"]

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
      
      // Update button URLs
      this.markBtnTarget.href = selectedOption.dataset.markUrl
      this.historyBtnTarget.href = selectedOption.dataset.historyUrl
      
      // Handle edit button visibility
      if (selectedOption.dataset.editUrl) {
        this.editBtnTarget.href = selectedOption.dataset.editUrl
        this.editBtnTarget.classList.remove('d-none')
      } else {
        this.editBtnTarget.classList.add('d-none')
      }
    } else {
      // Hide actions and show no selection message
      this.actionsTarget.classList.add('d-none')
      this.noSelectionTarget.classList.remove('d-none')
    }
  }
  
  change(event) {
    this.updateUI()
  }
} 