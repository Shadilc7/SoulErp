import { Controller } from "@hotwired/stimulus"

// Stimulus controller to manage certificate list selection, filtering and bulk actions
export default class extends Controller {
  connect() {
    this.selectAll = this.element.querySelector('#selectAll')
    this.sectionFilter = this.element.querySelector('#sectionFilter')
    this.publishBtn = this.element.querySelector('#publishSelected')
    this.deleteBtn = this.element.querySelector('#deleteSelected')
    this.unpublishBtn = this.element.querySelector('#unpublishSelected')
    this.downloadBtn = this.element.querySelector('#downloadSelected')
    this.regenerateBtn = this.element.querySelector('#regenerateSelected')

    this.onChange = this.onChange.bind(this)
    this.onClick = this.onClick.bind(this)

    document.addEventListener('change', this.onChange)
    document.addEventListener('click', this.onClick)

    // initialize UI
    this.applyFilter()
    this.updateButtons()

    // Show client-side flash if set in sessionStorage (fallback when server flash not shown after AJAX)
    const pendingNotice = sessionStorage.getItem('flash_notice')
    if (pendingNotice) {
      this.showFlash(pendingNotice)
      sessionStorage.removeItem('flash_notice')
    }
  }

  disconnect() {
    document.removeEventListener('change', this.onChange)
    document.removeEventListener('click', this.onClick)
  }

  getVisibleCheckboxes() {
    return Array.from(this.element.querySelectorAll('.certificate-checkbox:not(:disabled)'))
      .filter(cb => cb.closest('tr') && cb.closest('tr').offsetParent !== null)
  }

  updateSelectAllState() {
    if (!this.selectAll) return
    const visible = this.getVisibleCheckboxes()
    const checkedCount = visible.filter(cb => cb.checked).length
    this.selectAll.checked = visible.length > 0 && checkedCount === visible.length
    this.selectAll.indeterminate = checkedCount > 0 && checkedCount < visible.length
  }

  updateButtons() {
    const visibleChecked = this.getVisibleCheckboxes().filter(cb => cb.checked)
    const checkedCount = visibleChecked.length
    const publishedCheckedCount = visibleChecked.filter(cb => cb.dataset.published === 'true').length

    this.publishBtn.disabled = checkedCount === 0 || publishedCheckedCount === checkedCount // if all selected are published, nothing to publish
    if (this.unpublishBtn) this.unpublishBtn.disabled = publishedCheckedCount === 0
    if (this.downloadBtn) this.downloadBtn.disabled = checkedCount === 0
    if (this.deleteBtn) this.deleteBtn.disabled = checkedCount === 0 || publishedCheckedCount > 0
    if (this.regenerateBtn) this.regenerateBtn.disabled = checkedCount === 0
  }

  collectSelectedIds() {
    return this.getVisibleCheckboxes().filter(cb => cb.checked).map(cb => cb.value)
  }

  collectPublishedSelectedIds() {
    return this.getVisibleCheckboxes().filter(cb => cb.checked && cb.dataset.published === 'true').map(cb => cb.value)
  }

  onChange(e) {
    const t = e.target
    if (!t) return
    if (t.id === 'selectAll') {
      this.getVisibleCheckboxes().forEach(cb => cb.checked = t.checked)
      this.updateButtons()
      this.updateSelectAllState()
      return
    }

    if (t.matches && t.matches('.certificate-checkbox')) {
      this.updateButtons()
      this.updateSelectAllState()
      return
    }

    if (t.id === 'sectionFilter') {
      this.applyFilter()
      return
    }
  }

  onClick(e) {
    const t = e.target
    if (!t) return

    if (this.publishBtn && (t === this.publishBtn || this.publishBtn.contains(t))) {
      this.bulkPublish()
      return
    }

    if (this.unpublishBtn && (t === this.unpublishBtn || this.unpublishBtn.contains(t))) {
      this.bulkUnpublish()
      return
    }

    if (this.downloadBtn && (t === this.downloadBtn || this.downloadBtn.contains(t))) {
      this.bulkDownload()
      return
    }

    if (this.regenerateBtn && (t === this.regenerateBtn || this.regenerateBtn.contains(t))) {
      this.bulkRegenerate()
      return
    }

    if (this.deleteBtn && (t === this.deleteBtn || this.deleteBtn.contains(t))) {
      this.bulkDelete()
      return
    }

    // if a checkbox was clicked, update UI state
    if (t.matches && t.matches('.certificate-checkbox')) {
      this.updateButtons()
      this.updateSelectAllState()
      return
    }
  }

  applyFilter() {
    const selected = this.sectionFilter ? this.sectionFilter.value : ''
    this.element.querySelectorAll('.certificate-row').forEach(row => {
      const matches = !selected || row.dataset.section === selected
      row.style.display = matches ? '' : 'none'
    })
    // clear selections after filter
    this.element.querySelectorAll('.certificate-checkbox:not(:disabled)').forEach(cb => cb.checked = false)
    if (this.selectAll) { this.selectAll.checked = false; this.selectAll.indeterminate = false }
    this.updateButtons()
    this.updateSelectAllState()
  }

  bulkPublish() {
    const ids = this.collectSelectedIds().filter(id => {
      // filter out already published by checking DOM
      const cb = this.element.querySelector(`.certificate-checkbox[value="${id}"]`)
      return cb && cb.dataset.published !== 'true'
    })
    if (!ids.length) return
    if (!confirm(`Are you sure you want to publish ${ids.length} selected certificate(s)?`)) return
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    fetch('/institute_admin/reports/publish_multiple_certificates', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': token },
      body: JSON.stringify({ certificate_ids: ids })
    }).then(r => r.json()).then(data => {
      if (data.success) {
        sessionStorage.setItem('flash_notice', data.message || 'Published certificates')
        window.location.reload()
      } else {
        alert(data.message || 'Failed to publish')
      }
    }).catch(() => alert('Network error while publishing'))
  }

  bulkUnpublish() {
    const ids = this.collectPublishedSelectedIds()
    if (!ids.length) return
    if (!confirm(`Are you sure you want to unpublish ${ids.length} selected certificate(s)?`)) return
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    fetch('/institute_admin/reports/unpublish_multiple_certificates', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': token },
      body: JSON.stringify({ certificate_ids: ids })
    }).then(r => r.json()).then(data => {
      if (data.success) {
        sessionStorage.setItem('flash_notice', data.message || 'Unpublished certificates')
        window.location.reload()
      } else {
        alert(data.message || 'Failed to unpublish')
      }
    }).catch(() => alert('Network error while unpublishing'))
  }

  bulkDownload() {
    const ids = this.collectSelectedIds()
    if (!ids.length) return
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    fetch('/institute_admin/reports/download_multiple_certificates', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': token },
      body: JSON.stringify({ certificate_ids: ids })
    }).then(r => {
      if (!r.ok) throw new Error('Failed to prepare ZIP')
      return r.blob()
    }).then(blob => {
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `certificates_${new Date().toISOString().replace(/[:.]/g,'')}.zip`
      document.body.appendChild(a)
      a.click()
      a.remove()
      window.URL.revokeObjectURL(url)
    }).catch(err => { alert(err.message || 'Failed to download ZIP') })
  }

  bulkDelete() {
    const ids = this.collectSelectedIds()
    if (!ids.length) return
    if (!confirm(`Are you sure you want to delete ${ids.length} selected certificate(s)? This cannot be undone.`)) return
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    fetch('/institute_admin/reports/delete_multiple_certificates', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': token },
      body: JSON.stringify({ certificate_ids: ids })
    }).then(r => r.json()).then(data => {
      if (data.success) {
        sessionStorage.setItem('flash_notice', data.message || 'Deleted certificates')
        window.location.reload()
      } else {
        alert(data.message || 'Failed to delete')
      }
    }).catch(() => alert('Network error while deleting'))
  }

  bulkRegenerate() {
    const ids = this.collectSelectedIds()
    if (!ids.length) return
    if (!confirm(`Are you sure you want to regenerate ${ids.length} selected certificate(s)?`)) return
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    fetch('/institute_admin/reports/regenerate_multiple_certificates', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': token },
      body: JSON.stringify({ certificate_ids: ids })
    }).then(r => r.json()).then(data => {
      if (data.success) {
        // store notice in sessionStorage as a fallback and reload to reflect changes
        sessionStorage.setItem('flash_notice', data.message || 'Regenerated certificates')
        window.location.reload()
      } else {
        alert(data.message || 'Failed to regenerate')
      }
    }).catch(() => alert('Network error while regenerating'))
  }

  showFlash(message) {
    try {
      const container = document.querySelector('.content-wrapper') || document.body
      const alertDiv = document.createElement('div')
      alertDiv.className = 'alert alert-success alert-dismissible fade show'
      alertDiv.role = 'alert'
      alertDiv.innerHTML = `${message} <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>`
      container.insertBefore(alertDiv, container.firstChild)
      // auto-dismiss after 6 seconds
      setTimeout(() => { if (alertDiv && alertDiv.parentNode) alertDiv.remove() }, 6000)
    } catch (e) { console.warn('Failed to show flash', e) }
  }
}
