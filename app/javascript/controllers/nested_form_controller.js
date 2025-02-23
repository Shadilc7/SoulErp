import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template", "items"]

  connect() {
    this.wrapperClass = "nested-fields"
  }

  add(event) {
    event.preventDefault()
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    this.itemsTarget.insertAdjacentHTML('beforeend', content)
  }

  remove(event) {
    event.preventDefault()
    const item = event.target.closest('.option-item')
    item.remove()
  }
} 