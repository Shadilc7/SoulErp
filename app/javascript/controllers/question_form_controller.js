import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "titleInput", "optionsWrapper",
    "shortAnswerPreview", "paragraphPreview", "optionsSection",
    "datePreview", "timePreview", "numberPreview", "submitButton"
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
      case 'number':
        this.numberPreviewTarget.classList.remove('d-none')
        break
      case 'rating':
        this.showRatingOptions(true)
        break
    }
  }

  handleTypeChange(event) {
    const type = event.target.value
    console.log("Question type changed to:", type)
    
    // Hide all previews first
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
        console.log("Showing options section for:", type)
        this.optionsSectionTarget.classList.remove('d-none')
        this.optionsSectionTarget.style.display = 'block'
        this.updateOptionIndicators(type)
        
        // Ensure we have at least two options
        const optionsCount = this.optionsSectionTarget.querySelectorAll('.option-item').length
        if (optionsCount < 2) {
          // Use the nested form controller to add options
          const nestedFormController = this.application.getControllerForElementAndIdentifier(
            this.element, 'nested-form'
          )
          if (nestedFormController) {
            if (optionsCount === 0) {
              nestedFormController.add()
              nestedFormController.add()
            } else if (optionsCount === 1) {
              nestedFormController.add()
            }
          }
        }
        break
      case 'date':
        this.datePreviewTarget.classList.remove('d-none')
        break
      case 'time':
        this.timePreviewTarget.classList.remove('d-none')
        break
      case 'number':
        this.numberPreviewTarget.classList.remove('d-none')
        break
      case 'rating':
        this.showRatingOptions(true)
        break
    }
  }

  hideAllPreviews() {
    console.log("Hiding all previews")
    this.shortAnswerPreviewTarget.classList.add('d-none')
    this.paragraphPreviewTarget.classList.add('d-none')
    this.datePreviewTarget.classList.add('d-none')
    this.timePreviewTarget.classList.add('d-none')
    this.numberPreviewTarget.classList.add('d-none')
    
    // Hide options section but don't remove it from DOM
    this.optionsSectionTarget.classList.add('d-none')
    this.showRatingOptions(false)
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
    console.log("showOptionsContainer called with:", show)
    if (show) {
      this.optionsSectionTarget.classList.remove('d-none')
      this.optionsSectionTarget.style.display = 'block'
    } else {
      this.optionsSectionTarget.classList.add('d-none')
      this.optionsSectionTarget.style.display = 'none'
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