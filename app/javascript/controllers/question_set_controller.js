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
  }
  
  setupSelectAll() {
    console.log('Setting up select all functionality');
    const selectAllCheckbox = document.getElementById('select_all_questions');
    const questionCheckboxes = document.querySelectorAll('.question-checkbox');
    
    if (selectAllCheckbox && questionCheckboxes.length > 0) {
      console.log('Found select all checkbox and question checkboxes');
      
      // Handle select all checkbox change
      selectAllCheckbox.addEventListener('change', () => {
        console.log('Select all changed:', selectAllCheckbox.checked);
        const isChecked = selectAllCheckbox.checked;
        
        questionCheckboxes.forEach(checkbox => {
          checkbox.checked = isChecked;
        });
        
        this.updateCounter();
      });
      
      // Update select all checkbox state when individual checkboxes change
      questionCheckboxes.forEach(checkbox => {
        checkbox.addEventListener('change', () => {
          const allChecked = Array.from(questionCheckboxes).every(cb => cb.checked);
          selectAllCheckbox.checked = allChecked;
        });
      });
      
      // Initial state
      const allChecked = Array.from(questionCheckboxes).every(cb => cb.checked);
      selectAllCheckbox.checked = allChecked;
    } else {
      console.log('Could not find select all checkbox or question checkboxes');
      console.log('Select all checkbox:', selectAllCheckbox);
      console.log('Question checkboxes count:', questionCheckboxes.length);
    }
  }
} 