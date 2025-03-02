import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "titleInput", "startDate", "endDate", "submitButton",
    "typeSelect", "individualView", "sectionView",
    "sectionSelect", "sectionParticipantsView", "sectionParticipantsList",
    "sectionParticipantsCounter", "participantsCounter",
    "questionsCounter", "setsCounter",
    "selectAllQuestions",
    "selectAllSets",
    "selectAllSections",
    "sectionParticipantsContainer",
    "error"
  ]

  connect() {
    // Check if we're on the assignment creation page or the take assignment page
    const isCreationPage = this.hasQuestionsCounterTarget && this.hasSetsCounterTarget;
    
    if (isCreationPage) {
      this.updateAllCounters()
      this.validateForm()
      this.validateDates()
    }
    
    // Setup rating stars for both pages
    this.setupRatingStars()
  }

  handleTypeChange(event) {
    const selectedType = event.target.value
    
    // Show/hide appropriate views
    this.individualViewTarget.classList.toggle('d-none', selectedType !== 'individual')
    this.sectionViewTarget.classList.toggle('d-none', selectedType !== 'section')

    // Clear selections when switching types
    if (selectedType === 'individual') {
      this.clearSectionSelections()
    } else {
      this.clearParticipantSelections()
    }

    // Hide participants view when switching types
    if (selectedType === 'section') {
      this.sectionParticipantsViewTarget.classList.add('d-none')
      this.sectionParticipantsListTarget.innerHTML = ''
    }

    this.validateForm()
  }

  handleSectionChange(event) {
    const sectionId = event.target.value
    if (!sectionId) {
      this.sectionParticipantsViewTarget.classList.add('d-none')
      this.sectionParticipantsListTarget.innerHTML = ''
      return
    }

    // Fetch participants for the selected section
    fetch(`/institute_admin/sections/${sectionId}/participants`)
      .then(response => response.json())
      .then(participants => {
        this.sectionParticipantsViewTarget.classList.remove('d-none')
        
        // Generate checkboxes for participants, all pre-checked
        const participantsHtml = participants.map(participant => `
          <div class="form-check mb-2">
            <input type="checkbox" 
                   name="assignment[participant_ids][]" 
                   value="${participant.id}" 
                   id="participant_${participant.id}" 
                   class="form-check-input"
                   checked
                   data-action="change->assignment-form#updateSectionParticipantsCounter">
            <label class="form-check-label" for="participant_${participant.id}">
              ${participant.full_name}
            </label>
          </div>
        `).join('')
        
        this.sectionParticipantsListTarget.innerHTML = participantsHtml
        this.updateSectionParticipantsCounter()
      })
  }

  updateSectionParticipantsCount() {
    const count = this.sectionParticipantsListTarget.querySelectorAll('input:checked').length
    this.sectionParticipantsCounterTarget.textContent = `${count} Selected`
    this.validateForm()
  }

  updateParticipantsCount() {
    if (!this.hasParticipantsCounterTarget) return;
    
    const count = document.querySelectorAll('input[name="assignment[participant_ids][]"]:checked').length
    this.participantsCounterTarget.textContent = `${count} Selected`
    this.validateForm()
  }

  clearSectionSelections() {
    this.element.querySelectorAll('input[name="assignment[section_ids][]"]').forEach(checkbox => {
      checkbox.checked = false
    })
  }

  clearParticipantSelections() {
    this.element.querySelectorAll('input[name="assignment[participant_ids][]"]').forEach(checkbox => {
      checkbox.checked = false
    })
  }

  validateDates() {
    const startDate = this.element.querySelector('#assignment_start_date')
    const endDate = this.element.querySelector('#assignment_end_date')
    
    if (!startDate || !endDate) return;

    startDate.addEventListener('change', () => {
      const minEnd = startDate.value
      endDate.min = minEnd
      if (endDate.value && endDate.value < minEnd) {
        endDate.value = minEnd
      }
    })

    endDate.addEventListener('change', () => {
      const maxStart = endDate.value
      if (startDate.value && startDate.value > maxStart) {
        startDate.value = maxStart
      }
    })
  }

  updateQuestionsCount() {
    if (!this.hasQuestionsCounterTarget) return;
    
    const count = document.querySelectorAll('input[name="assignment[question_ids][]"]:checked').length
    this.questionsCounterTarget.textContent = `${count} Selected`
    this.validateForm()
  }

  updateSetsCount() {
    if (!this.hasSetsCounterTarget) return;
    
    const count = document.querySelectorAll('input[name="assignment[question_set_ids][]"]:checked').length
    this.setsCounterTarget.textContent = `${count} Selected`
    this.validateForm()
  }

  updateAllCounters() {
    if (this.hasQuestionsCounterTarget) this.updateQuestionsCount()
    if (this.hasSetsCounterTarget) this.updateSetsCount()
    if (this.hasParticipantsCounterTarget) this.updateParticipantsCount()
  }

  validateForm() {
    // Skip validation if we're not on the creation page
    if (!this.hasTitleInputTarget || !this.hasStartDateTarget || !this.hasEndDateTarget || !this.hasSubmitButtonTarget) return;
    
    const title = this.titleInputTarget.value.trim()
    const startDate = this.startDateTarget.value
    const endDate = this.endDateTarget.value
    const hasQuestions = this.hasQuestionsSelected()
    const hasAssignees = this.hasAssigneesSelected()

    this.submitButtonTarget.disabled = 
      !title || !startDate || !endDate || !hasQuestions || !hasAssignees
  }

  hasQuestionsSelected() {
    // If we're not on the creation page, return true
    if (!this.hasQuestionsCounterTarget && !this.hasSetsCounterTarget) return true;
    
    const questions = document.querySelectorAll('input[name="assignment[question_ids][]"]:checked').length
    const sets = document.querySelectorAll('input[name="assignment[question_set_ids][]"]:checked').length
    return questions > 0 || sets > 0
  }

  hasAssigneesSelected() {
    // If we're not on the creation page, return true
    if (!this.hasTypeSelectTarget) return true;
    
    const assignmentType = this.typeSelectTarget.value
    
    if (assignmentType === 'section') {
      return this.sectionParticipantsListTarget.querySelectorAll('input:checked').length > 0
    } else {
      return document.querySelectorAll('input[name="assignment[participant_ids][]"]:checked').length > 0
    }
  }

  toggleAllQuestions(event) {
    const checked = event.target.checked
    this.element.querySelectorAll('.question-checkbox').forEach(checkbox => {
      checkbox.checked = checked
    })
    this.updateCounter()
  }

  toggleAllQuestionSets(event) {
    const checked = event.target.checked
    this.element.querySelectorAll('.question-set-checkbox').forEach(checkbox => {
      checkbox.checked = checked
    })
    this.updateCounter()
  }

  updateSelectAllQuestions() {
    const totalQuestions = this.element.querySelectorAll('.question-checkbox').length
    const checkedQuestions = this.element.querySelectorAll('.question-checkbox:checked').length
    this.selectAllQuestionsTarget.checked = totalQuestions === checkedQuestions
  }

  updateSelectAllSets() {
    const totalSets = this.element.querySelectorAll('.question-set-checkbox').length
    const checkedSets = this.element.querySelectorAll('.question-set-checkbox:checked').length
    this.selectAllSetsTarget.checked = totalSets === checkedSets
  }

  toggleAllSections(event) {
    const checked = event.target.checked
    this.element.querySelectorAll('.section-checkbox').forEach(checkbox => {
      checkbox.checked = checked
      this.handleSectionSelection({ target: checkbox })
    })
  }

  handleSectionSelection(event) {
    const checkbox = event.target
    const sectionId = checkbox.dataset.sectionId
    const sectionName = checkbox.nextElementSibling.textContent.trim()
    const participantsContainerId = `section_${sectionId}_participants`
    
    if (checkbox.checked) {
      fetch(`/institute_admin/sections/${sectionId}/participants`)
        .then(response => response.json())
        .then(participants => {
          const containerHtml = this.createParticipantsContainer(sectionId, participants)
          this.sectionParticipantsContainerTarget.insertAdjacentHTML('beforeend', containerHtml)
          
          // Set the section name
          const container = document.getElementById(participantsContainerId)
          container.querySelector('.section-name').textContent = sectionName
        })
    } else {
      const container = document.getElementById(participantsContainerId)
      if (container) container.remove()
    }
    
    this.updateSelectAllSections()
  }

  createParticipantsContainer(sectionId, participants) {
    const participantsHtml = participants.map(participant => `
      <div class="form-check">
        <input type="checkbox" 
               name="assignment[participant_ids][]" 
               value="${participant.id}" 
               id="participant_${participant.id}" 
               class="form-check-input section-${sectionId}-participant"
               checked
               data-action="change->assignment-form#updateParticipantsCounter change->assignment-form#updateSectionSelectAll"
               data-section-id="${sectionId}">
        <label class="form-check-label" for="participant_${participant.id}">
          ${participant.full_name}
        </label>
      </div>
    `).join('')

    return `
      <div id="section_${sectionId}_participants" class="card border mb-3">
        <div class="card-header bg-light d-flex justify-content-between align-items-center py-2">
          <div>
            <h6 class="mb-0 section-name"></h6>
          </div>
          <div class="d-flex align-items-center gap-2">
            <div class="form-check mb-0">
              <input type="checkbox" 
                     id="select_all_participants_${sectionId}" 
                     class="form-check-input"
                     checked
                     data-action="change->assignment-form#toggleSectionParticipants"
                     data-section-id="${sectionId}">
              <label class="form-check-label small" for="select_all_participants_${sectionId}">
                Select All
              </label>
            </div>
           
          </div>
        </div>
        <div class="card-body">
          ${participantsHtml}
        </div>
      </div>
    `
  }

  updateSelectAllSections() {
    const totalSections = this.element.querySelectorAll('.section-checkbox').length
    const checkedSections = this.element.querySelectorAll('.section-checkbox:checked').length
    this.selectAllSectionsTarget.checked = totalSections === checkedSections
  }

  toggleSectionParticipants(event) {
    const checkbox = event.target
    const sectionId = checkbox.dataset.sectionId
    const checked = checkbox.checked
    
    this.element.querySelectorAll(`.section-${sectionId}-participant`).forEach(participantCheckbox => {
      participantCheckbox.checked = checked
    })
    
    this.updateParticipantsCounter()
  }

  updateSectionSelectAll(event) {
    const checkbox = event.target
    const sectionId = checkbox.dataset.sectionId
    const selectAllCheckbox = document.getElementById(`select_all_participants_${sectionId}`)
    
    const totalParticipants = this.element.querySelectorAll(`.section-${sectionId}-participant`).length
    const checkedParticipants = this.element.querySelectorAll(`.section-${sectionId}-participant:checked`).length
    
    selectAllCheckbox.checked = totalParticipants === checkedParticipants
  }

  updateParticipantsCounter() {
    const count = document.querySelectorAll('input[name="assignment[participant_ids][]"]:checked').length
    this.participantsCounterTarget.textContent = `${count} Selected`
    this.validateForm()
  }

  validateField(event) {
    const field = event.target
    const questionId = field.dataset.questionId
    const errorElement = this.errorTargets.find(el => el.dataset.questionId === questionId)
    
    if (!errorElement) return
    
    if (field.type === 'checkbox') {
      // For checkboxes, check if at least one is checked
      const checkboxes = document.querySelectorAll(`input[name="${field.name}"]`)
      const isValid = Array.from(checkboxes).some(cb => cb.checked)
      this.toggleValidation(field, errorElement, isValid)
    } else if (field.type === 'radio') {
      // For radio buttons, check if any in the group is checked
      const radios = document.querySelectorAll(`input[name="${field.name}"]`)
      const isValid = Array.from(radios).some(r => r.checked)
      this.toggleValidation(field, errorElement, isValid)
    } else {
      // For other inputs, check if they have a value
      const isValid = field.value.trim() !== ''
      this.toggleValidation(field, errorElement, isValid)
    }
  }
  
  toggleValidation(field, errorElement, isValid) {
    if (isValid) {
      field.classList.remove('is-invalid')
      errorElement.style.display = 'none'
    } else {
      field.classList.add('is-invalid')
      errorElement.style.display = 'block'
    }
  }

  setupRatingStars() {
    console.log("Setting up rating stars");
    
    // Find all star rating containers
    const ratingContainers = document.querySelectorAll('.star-rating');
    console.log(`Found ${ratingContainers.length} rating containers`);
    
    if (!ratingContainers.length) return;
    
    ratingContainers.forEach(container => {
      const inputs = container.querySelectorAll('input[type="radio"]');
      const labels = container.querySelectorAll('label');
      
      if (!inputs.length || !labels.length) return;
      
      const questionId = inputs[0]?.dataset.questionId;
      const valueDisplay = document.getElementById(`rating_value_${questionId}`);
      
      console.log(`Setting up rating for question ${questionId} with ${inputs.length} inputs and ${labels.length} labels`);
      
      // Add click event to each label
      labels.forEach(label => {
        const starIcon = label.querySelector('i');
        
        // Replace with empty star initially
        if (starIcon) {
          starIcon.classList.remove('bi-star-fill');
          starIcon.classList.add('bi-star');
        }
        
        label.addEventListener('click', (event) => {
          event.preventDefault();
          console.log(`Star clicked: ${label.getAttribute('for')}`);
          
          const input = document.getElementById(label.getAttribute('for'));
          if (input) {
            input.checked = true;
            
            // Get the star value from the input ID
            const starValue = parseInt(input.value);
            console.log(`Selected star value: ${starValue}`);
            
            // Update all stars
            labels.forEach(l => {
              const icon = l.querySelector('i');
              const starNum = parseInt(l.getAttribute('for').split('_')[0].replace('star', ''));
              
              if (starNum <= starValue) {
                icon.classList.remove('bi-star');
                icon.classList.add('bi-star-fill');
                icon.style.color = '#FFD700';
              } else {
                icon.classList.remove('bi-star-fill');
                icon.classList.add('bi-star');
                icon.style.color = '#ddd';
              }
            });
            
            // Only call validateField if the method exists
            if (this.validateField) {
              this.validateField({ target: input });
            }
            
            // Update the rating value display
            if (valueDisplay) {
              valueDisplay.textContent = `${starValue} ${starValue === 1 ? 'star' : 'stars'} selected`;
            }
          }
        });
      });
      
      // Add hover effects to the container
      container.addEventListener('mouseover', (event) => {
        if (event.target.tagName === 'I' || event.target.tagName === 'LABEL') {
          const label = event.target.tagName === 'I' ? event.target.parentNode : event.target;
          const value = parseInt(label.getAttribute('for').split('_')[0].replace('star', ''));
          
          // Update all stars on hover
          labels.forEach(l => {
            const icon = l.querySelector('i');
            const starNum = parseInt(l.getAttribute('for').split('_')[0].replace('star', ''));
            
            if (starNum <= value) {
              icon.classList.remove('bi-star');
              icon.classList.add('bi-star-fill');
              icon.style.color = '#FFD700';
            } else {
              icon.classList.remove('bi-star-fill');
              icon.classList.add('bi-star');
              icon.style.color = '#ddd';
            }
          });
        }
      });
      
      // Remove hover effect when leaving the container
      container.addEventListener('mouseleave', () => {
        // Reset to selected state
        const selectedInput = Array.from(inputs).find(input => input.checked);
        const selectedValue = selectedInput ? parseInt(selectedInput.value) : 0;
        
        labels.forEach(l => {
          const icon = l.querySelector('i');
          const starNum = parseInt(l.getAttribute('for').split('_')[0].replace('star', ''));
          
          if (starNum <= selectedValue) {
            icon.classList.remove('bi-star');
            icon.classList.add('bi-star-fill');
            icon.style.color = '#FFD700';
          } else {
            icon.classList.remove('bi-star-fill');
            icon.classList.add('bi-star');
            icon.style.color = '#ddd';
          }
        });
      });
    });
  }
} 