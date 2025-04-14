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
        
        // Hide correct checkboxes for these question types
        this.hideCorrectCheckboxes()
        break
      case 'yes_or_no':
        this.optionsSectionTarget.classList.remove('d-none')
        this.updateOptionIndicators('multiple_choice')
        this.showOptionsContainer(true)
        // For Yes/No, we'll auto-populate the options
        this.createYesNoOptions()
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
    
    // If coming from yes_or_no type, restore correct checkboxes
    if (type !== 'yes_or_no') {
      this.restoreCorrectCheckboxes()
    }
    
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
        
        // Hide correct checkboxes for these question types
        this.hideCorrectCheckboxes()
        break
      case 'yes_or_no':
        console.log("Showing Yes/No options")
        this.optionsSectionTarget.classList.remove('d-none')
        this.optionsSectionTarget.style.display = 'block'
        this.updateOptionIndicators('multiple_choice')
        
        // Clear existing options and create Yes/No options
        this.createYesNoOptions()
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
    
    // Hide correct checkboxes for multiple choice, checkbox, dropdown, and yes/no
    if (['multiple_choice', 'checkboxes', 'dropdown', 'yes_or_no'].includes(questionType)) {
      this.hideCorrectCheckboxes()
    }
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

  createYesNoOptions() {
    // Clear existing options first
    const optionsContainer = this.optionsSectionTarget.querySelector('[data-nested-form-target="items"]')
    if (optionsContainer) {
      optionsContainer.innerHTML = ''
      
      // Use the nested form controller to add Yes/No options
      const nestedFormController = this.application.getControllerForElementAndIdentifier(
        this.element, 'nested-form'
      )
      
      if (nestedFormController) {
        // Hide the "Add Option" button for Yes/No questions
        const addOptionButton = this.optionsSectionTarget.querySelector('button[data-action="nested-form#add"]')
        if (addOptionButton) {
          addOptionButton.style.display = 'none'
        }
        
        // Add two options (Yes and No) programmatically
        // First, add the options
        nestedFormController.add()
        nestedFormController.add()
        
        // Now get all option items
        const optionItems = optionsContainer.querySelectorAll('.option-item')
        
        // Set values for Yes and No options
        if (optionItems.length >= 2) {
          const yesOption = optionItems[0]
          const noOption = optionItems[1]
          
          // Set text for Yes option
          const yesTextField = yesOption.querySelector('input[type="text"]')
          if (yesTextField) yesTextField.value = 'Yes'
          
          // Set text for No option
          const noTextField = noOption.querySelector('input[type="text"]')
          if (noTextField) noTextField.value = 'No'
          
          // Hide correct checkboxes for both options
          optionItems.forEach(option => {
            const correctCheckboxContainer = option.querySelector('.form-check')
            if (correctCheckboxContainer) {
              correctCheckboxContainer.style.display = 'none'
            }
            
            // Hide delete buttons
            const deleteButton = option.querySelector('button[data-action="nested-form#remove"]')
            if (deleteButton) {
              deleteButton.style.display = 'none'
            }
          })
          
          // Also hide correct checkboxes in the template for any new options
          const template = this.element.querySelector('[data-nested-form-target="template"]')
          if (template) {
            const templateCorrectCheckbox = template.querySelector('.form-check')
            if (templateCorrectCheckbox) {
              templateCorrectCheckbox.dataset.yesNoHidden = 'true'
            }
          }
        }
      }
    }
  }

  restoreCorrectCheckboxes() {
    // Restore visibility of all correct checkboxes
    const checkboxContainers = this.element.querySelectorAll('.form-check')
    checkboxContainers.forEach(container => {
      container.style.display = ''
    })
    
    // Also restore in template
    const template = this.element.querySelector('[data-nested-form-target="template"]')
    if (template) {
      const templateCorrectCheckbox = template.querySelector('.form-check')
      if (templateCorrectCheckbox) {
        delete templateCorrectCheckbox.dataset.yesNoHidden
      }
    }
    
    // Restore the "Add Option" button
    const addOptionButton = this.optionsSectionTarget.querySelector('button[data-action="nested-form#add"]')
    if (addOptionButton) {
      addOptionButton.style.display = ''
    }
    
    // Restore delete buttons
    const optionItems = this.element.querySelectorAll('.option-item')
    optionItems.forEach(option => {
      // Restore delete buttons
      const deleteButton = option.querySelector('button[data-action="nested-form#remove"]')
      if (deleteButton) {
        deleteButton.style.display = ''
      }
    })
  }

  hideCorrectCheckboxes() {
    // Hide correct checkboxes for all options
    const optionItems = this.element.querySelectorAll('.option-item')
    optionItems.forEach(option => {
      const correctCheckboxContainer = option.querySelector('.form-check')
      if (correctCheckboxContainer) {
        correctCheckboxContainer.style.display = 'none'
      }
    })
    
    // Also hide correct checkboxes in the template for any new options
    const template = this.element.querySelector('[data-nested-form-target="template"]')
    if (template) {
      const templateCorrectCheckbox = template.querySelector('.form-check')
      if (templateCorrectCheckbox) {
        templateCorrectCheckbox.style.display = 'none'
      }
    }
  }
} 