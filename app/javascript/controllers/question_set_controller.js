import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["titleInput", "counter", "submitButton"]

  connect() {
    this.validateForm()
    this.updateCounter()
  }

  validateForm() {
    const title = this.titleInputTarget.value.trim()
    const selectedQuestions = document.querySelectorAll('input[name="question_set[question_ids][]"]:checked').length
    
    this.submitButtonTarget.disabled = title.length === 0 || selectedQuestions === 0
  }

  updateCounter() {
    const count = document.querySelectorAll('input[name="question_set[question_ids][]"]:checked').length
    this.counterTarget.textContent = `${count} Selected`
    this.validateForm()
  }
} 