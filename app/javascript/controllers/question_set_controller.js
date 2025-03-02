import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["titleInput", "counter", "submitButton"]

  connect() {
    console.log("Question Set Controller connected");
    this.validateForm();
    this.updateCounter();
    this.setupSelectAll();
  }

  validateForm() {
    const title = this.titleInputTarget.value.trim();
    const selectedQuestions = document.querySelectorAll('input[name="question_set[question_ids][]"]:checked').length;
    
    if (title.length === 0 || selectedQuestions === 0) {
      this.submitButtonTarget.disabled = true;
      this.submitButtonTarget.classList.remove('btn-primary');
      this.submitButtonTarget.classList.add('btn-secondary');
    } else {
      this.submitButtonTarget.disabled = false;
      this.submitButtonTarget.classList.remove('btn-secondary');
      this.submitButtonTarget.classList.add('btn-primary');
    }
  }

  updateCounter() {
    const count = document.querySelectorAll('input[name="question_set[question_ids][]"]:checked').length;
    this.counterTarget.textContent = `${count} Selected`;
    this.validateForm();
    
    // Update select all checkbox state
    this.updateSelectAllState();
  }
  
  updateSelectAllState() {
    const selectAllCheckbox = document.getElementById('select_all_questions');
    if (!selectAllCheckbox) return;
    
    const questionCheckboxes = document.querySelectorAll('.question-checkbox');
    if (questionCheckboxes.length === 0) return;
    
    const allChecked = Array.from(questionCheckboxes).every(cb => cb.checked);
    selectAllCheckbox.checked = allChecked;
  }
  
  setupSelectAll() {
    console.log('Setting up select all functionality');
    const selectAllCheckbox = document.getElementById('select_all_questions');
    if (!selectAllCheckbox) {
      console.error('Select all checkbox not found');
      return;
    }
    
    const questionCheckboxes = document.querySelectorAll('.question-checkbox');
    if (questionCheckboxes.length === 0) {
      console.error('No question checkboxes found');
      return;
    }
    
    console.log(`Found select all checkbox and ${questionCheckboxes.length} question checkboxes`);
    
    // Handle select all checkbox change
    selectAllCheckbox.addEventListener('change', (event) => {
      console.log('Select all changed:', event.target.checked);
      const isChecked = event.target.checked;
      
      questionCheckboxes.forEach(checkbox => {
        checkbox.checked = isChecked;
      });
      
      this.updateCounter();
    });
  }
} 