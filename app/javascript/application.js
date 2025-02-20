// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Handle dynamic option fields
document.addEventListener('turbo:load', () => {
  const addOptionButton = document.getElementById('add-option')
  if (addOptionButton) {
    addOptionButton.addEventListener('click', () => {
      const container = document.getElementById('options-container')
      const newOption = document.createElement('div')
      newOption.className = 'input-group mb-2'
      newOption.innerHTML = `
        <input type="text" name="question[options][]" class="form-control">
        <button type="button" class="btn btn-outline-danger remove-option">
          <i class="bi bi-trash"></i>
        </button>
      `
      container.appendChild(newOption)
    })
  }

  document.addEventListener('click', (e) => {
    if (e.target.closest('.remove-option')) {
      e.target.closest('.input-group').remove()
    }
  })
})
