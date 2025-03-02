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
    this.toggleFields()
    this.updateRatingPreview()
    
    // Add event listener for question type change
    select?.addEventListener('change', this.handleTypeChange.bind(this))
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
        this.showOptionsContainer(true)
        break
      case 'date':
        this.datePreviewTarget.classList.remove('d-none')
        break
      case 'time':
        this.timePreviewTarget.classList.remove('d-none')
        break
      case 'rating':
        this.showRatingOptions(true)
        break
    }
  }

  handleTypeChange(event) {
    // Hide all previews
    this.hideAllPreviews()

    // Show appropriate preview based on type
    const selectedType = event.target.value
    if (!selectedType) return

    // Hide all option-specific elements
    this.showOptionsContainer(false)
    this.showRatingOptions(false)

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
        this.showOptionsContainer(true)
        
        // Trigger the nested form controller to add default options if needed
        const nestedFormController = this.application.getControllerForElementAndIdentifier(
          document.querySelector('[data-controller="nested-form"]'),
          'nested-form'
        )
        if (nestedFormController) {
          const existingOptions = document.querySelectorAll('.option-item')
          if (existingOptions.length === 0) {
            nestedFormController.add()
            nestedFormController.add()
          }
        }
        break
      case 'date':
        this.datePreviewTarget.classList.remove('d-none')
        break
      case 'time':
        this.timePreviewTarget.classList.remove('d-none')
        break
      case 'rating':
        this.showRatingOptions(true)
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

  showOptionsContainer(show) {
    const optionsContainer = document.querySelector('.options-container')
    if (optionsContainer) {
      optionsContainer.style.display = show ? 'block' : 'none'
    }
  }
  
  showRatingOptions(show) {
    const ratingOptions = document.querySelector('.rating-options')
    if (ratingOptions) {
      ratingOptions.style.display = show ? 'flex' : 'none'
    }
  }
  
  toggleFields() {
    const questionType = document.getElementById('question_question_type').value
    
    // Hide/show options container based on question type
    this.showOptionsContainer(['multiple_choice', 'checkboxes', 'dropdown'].includes(questionType))
    
    // Hide/show rating options based on question type
    this.showRatingOptions(questionType === 'rating')
  }
  
  updateRatingPreview() {
    const maxRatingSelect = document.getElementById('question_max_rating')
    if (maxRatingSelect) {
      maxRatingSelect.addEventListener('change', () => {
        const maxRating = parseInt(maxRatingSelect.value)
        const previewContainer = document.querySelector('.rating-preview')
        
        // Clear existing stars
        previewContainer.innerHTML = ''
        
        // Add new stars based on selected max rating
        for (let i = 1; i <= maxRating; i++) {
          const star = document.createElement('i')
          star.className = 'bi bi-star-fill text-warning fs-3 me-1'
          previewContainer.appendChild(star)
        }
      })
    }
  }
  
  toggleRequired(event) {
    // This method handles the required checkbox toggle
    const isRequired = event.target.checked
    console.log(`Question is now ${isRequired ? 'required' : 'optional'}`)
    
    // You can add additional logic here if needed
    // For example, updating UI elements based on the required status
  }
} 