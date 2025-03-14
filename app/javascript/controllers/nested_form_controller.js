import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template", "items"]

  connect() {
    console.log("Nested form controller connected")
    
    // Add at least two options for question types that require options
    const questionType = document.getElementById('question_question_type')?.value
    const existingOptions = this.itemsTarget.querySelectorAll('.option-item')
    
    console.log("Question type:", questionType, "Existing options:", existingOptions.length)
    
    if (['multiple_choice', 'checkboxes', 'dropdown'].includes(questionType) && existingOptions.length === 0) {
      console.log("Adding default options")
      this.add()
      this.add()
    }
  }

  add(event) {
    if (event) event.preventDefault()
    console.log("Adding new option")
    
    // Get the template HTML and replace NEW_RECORD with a unique ID
    const timestamp = new Date().getTime()
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, timestamp)
    
    // Append the new option to the items container
    this.itemsTarget.insertAdjacentHTML('beforeend', content)
    
    // Set default text for the newly added option
    const newOption = this.itemsTarget.lastElementChild
    const textField = newOption.querySelector('input[name*="[text]"]')
    if (textField) {
      const optionCount = this.itemsTarget.querySelectorAll('.option-item').length
      textField.value = `Option ${optionCount}`
      
      // Add event listener to ensure field is never empty
      textField.addEventListener('blur', () => {
        if (!textField.value.trim()) {
          textField.value = `Option ${optionCount}`
        }
      })
      
      // Add event listener to ensure field is never empty on form submission
      const form = textField.closest('form')
      if (form) {
        form.addEventListener('submit', () => {
          if (!textField.value.trim()) {
            textField.value = `Option ${optionCount}`
          }
        })
      }
    }
    
    // Update the option indicators based on the current question type
    this.updateOptionIndicators()
  }

  remove(event) {
    event.preventDefault()
    
    const item = event.target.closest('.option-item')
    const allItems = this.itemsTarget.querySelectorAll('.option-item')
    
    // Don't allow removing if there are only 2 options left
    if (allItems.length <= 2) {
      console.log("Cannot remove option - minimum 2 required")
      return
    }
    
    // If this is a persisted record, mark it for destruction instead of removing from DOM
    const destroyInput = item.querySelector('input[name*="_destroy"]')
    if (destroyInput) {
      destroyInput.value = "1"
      item.style.display = "none"
    } else {
      // Otherwise just remove it from the DOM
      item.remove()
    }
  }
  
  updateOptionIndicators() {
    const questionType = document.getElementById('question_question_type')?.value
    if (!questionType) return
    
    console.log("Updating option indicators for", questionType)
    
    const indicators = document.querySelectorAll('.option-indicator i')
    indicators.forEach(indicator => {
      indicator.className = `bi ${
        questionType === 'multiple_choice' ? 'bi-circle' :
        questionType === 'checkboxes' ? 'bi-square' :
        'bi-chevron-down'
      }`
    })
  }
} 