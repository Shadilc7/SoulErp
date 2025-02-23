import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "titleInput", "optionsWrapper",
    "shortAnswerPreview", "paragraphPreview", "optionsSection",
    "datePreview", "timePreview", "submitButton"
  ]

  connect() {
    // Get initial question type from select
    const select = this.element.querySelector('select[name="question[question_type]"]')
    if (select) {
      this.handleInitialType(select.value)
    }
    this.validateForm()
  }

  handleInitialType(type) {
    // Hide all previews
    this.hideAllPreviews()

    // Show appropriate preview based on type
    switch(type) {
      case 'short_answer':
        this.shortAnswerPreviewTarget.classList.remove('d-none')
        break
      case 'paragraph':
        this.paragraphPreviewTarget.classList.remove('d-none')
        break
      case 'multiple_choice':
      case 'checkboxes':
      case 'dropdown':
        this.optionsSectionTarget.classList.remove('d-none')
        this.updateOptionIndicators(type)
        break
      case 'date':
        this.datePreviewTarget.classList.remove('d-none')
        break
      case 'time':
        this.timePreviewTarget.classList.remove('d-none')
        break
    }
  }

  handleTypeChange(event) {
    // Hide all previews
    this.hideAllPreviews()

    // Show appropriate preview based on type
    const selectedType = event.target.value
    if (!selectedType) return

    switch(selectedType) {
      case 'short_answer':
        this.shortAnswerPreviewTarget.classList.remove('d-none')
        break
      case 'paragraph':
        this.paragraphPreviewTarget.classList.remove('d-none')
        break
      case 'multiple_choice':
      case 'checkboxes':
      case 'dropdown':
        this.optionsSectionTarget.classList.remove('d-none')
        this.updateOptionIndicators(selectedType)
        break
      case 'date':
        this.datePreviewTarget.classList.remove('d-none')
        break
      case 'time':
        this.timePreviewTarget.classList.remove('d-none')
        break
    }
  }

  hideAllPreviews() {
    this.shortAnswerPreviewTarget.classList.add('d-none')
    this.paragraphPreviewTarget.classList.add('d-none')
    this.optionsSectionTarget.classList.add('d-none')
    this.datePreviewTarget.classList.add('d-none')
    this.timePreviewTarget.classList.add('d-none')
  }

  updateOptionIndicators(type) {
    const indicators = this.element.querySelectorAll('.option-indicator i')
    indicators.forEach(indicator => {
      indicator.className = `bi ${
        type === 'multiple_choice' ? 'bi-circle' :
        type === 'checkboxes' ? 'bi-square' :
        'bi-chevron-down'
      }`
    })
  }

  validateForm() {
    const title = this.titleInputTarget.value.trim()
    this.submitButtonTarget.disabled = title.length === 0
  }
} 