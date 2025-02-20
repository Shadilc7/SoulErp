import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "optionsContainer", "answerContainer" ]

  connect() {
    this.updateFormFields()
  }

  updateFormFields() {
    const questionType = this.element.value
    
    switch(questionType) {
      case 'multiple_choice':
      case 'single_choice':
        this.optionsContainerTarget.style.display = 'block'
        this.answerContainerTarget.style.display = 'none'
        break
      case 'true_false':
        this.optionsContainerTarget.style.display = 'none'
        this.answerContainerTarget.style.display = 'block'
        break
      default:
        this.optionsContainerTarget.style.display = 'none'
        this.answerContainerTarget.style.display = 'block'
    }
  }
} 