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
    
    if (title.length === 0 || selectedQuestions === 0) {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.classList.remove('btn-primary')
      this.submitButtonTarget.classList.add('btn-secondary')
    } else {
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.classList.remove('btn-secondary')
      this.submitButtonTarget.classList.add('btn-primary')
    }
  }

  updateCounter() {
    const count = document.querySelectorAll('input[name="question_set[question_ids][]"]:checked').length
    this.counterTarget.textContent = `${count} Selected`
    this.validateForm()
  }
} 