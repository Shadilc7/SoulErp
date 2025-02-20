import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "template" ]

  connect() {
    this.wrapperClass = "nested-fields"
  }

  add(event) {
    event.preventDefault()
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    this.element.insertAdjacentHTML('beforeend', content)
  }

  remove(event) {
    event.preventDefault()
    const wrapper = event.target.closest(`.${this.wrapperClass}`)
    
    if (wrapper.dataset.newRecord === "true") {
      wrapper.remove()
    } else {
      wrapper.style.display = 'none'
      const destroyField = wrapper.querySelector("input[name*='_destroy']")
      destroyField.value = '1'
    }
  }
} 