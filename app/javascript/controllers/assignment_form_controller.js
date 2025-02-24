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
    "sectionParticipantsContainer"
  ]

  connect() {
    this.updateAllCounters()
    this.validateForm()
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
    const startDate = new Date(this.startDateTarget.value)
    const endDate = new Date(this.endDateTarget.value)

    if (endDate < startDate) {
      this.endDateTarget.value = this.startDateTarget.value
    }
    this.validateForm()
  }

  updateQuestionsCount() {
    const count = document.querySelectorAll('input[name="assignment[question_ids][]"]:checked').length
    this.questionsCounterTarget.textContent = `${count} Selected`
    this.validateForm()
  }

  updateSetsCount() {
    const count = document.querySelectorAll('input[name="assignment[question_set_ids][]"]:checked').length
    this.setsCounterTarget.textContent = `${count} Selected`
    this.validateForm()
  }

  updateAllCounters() {
    this.updateQuestionsCount()
    this.updateSetsCount()
    this.updateParticipantsCount()
  }

  validateForm() {
    const title = this.titleInputTarget.value.trim()
    const startDate = this.startDateTarget.value
    const endDate = this.endDateTarget.value
    const hasQuestions = this.hasQuestionsSelected()
    const hasAssignees = this.hasAssigneesSelected()

    this.submitButtonTarget.disabled = 
      !title || !startDate || !endDate || !hasQuestions || !hasAssignees
  }

  hasQuestionsSelected() {
    const questions = document.querySelectorAll('input[name="assignment[question_ids][]"]:checked').length
    const sets = document.querySelectorAll('input[name="assignment[question_set_ids][]"]:checked').length
    return questions > 0 || sets > 0
  }

  hasAssigneesSelected() {
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
} 