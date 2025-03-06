import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "backdrop"]

  connect() {
    // Handle initial mobile state
    this.checkMobileState()
    
    // Listen for window resize
    window.addEventListener('resize', this.checkMobileState.bind(this))
    
    // Add event listeners to sidebar links to preserve scroll position
    this.setupSidebarLinkListeners()
  }

  toggle() {
    const sidebar = document.getElementById('sidebar')
    if (sidebar) {
      sidebar.classList.toggle('show')
      this.backdropTarget.classList.toggle('show')
      document.body.style.overflow = sidebar.classList.contains('show') ? 'hidden' : ''
    }
  }

  hide() {
    const sidebar = document.getElementById('sidebar')
    if (sidebar) {
      sidebar.classList.remove('show')
      this.backdropTarget.classList.remove('show')
      document.body.style.overflow = ''
    }
  }

  checkMobileState() {
    if (window.innerWidth >= 992) {
      this.hide()
    }
  }
  
  setupSidebarLinkListeners() {
    const sidebar = document.getElementById('sidebar')
    if (!sidebar) return
    
    // Store the current scroll position in localStorage when clicking a link
    const links = sidebar.querySelectorAll('a.nav-link')
    links.forEach(link => {
      link.addEventListener('click', () => {
        localStorage.setItem('sidebarScrollPosition', sidebar.scrollTop)
      })
    })
    
    // Restore scroll position after page load
    if (localStorage.getItem('sidebarScrollPosition')) {
      const scrollPosition = parseInt(localStorage.getItem('sidebarScrollPosition'))
      sidebar.scrollTop = scrollPosition
    }
  }

  disconnect() {
    window.removeEventListener('resize', this.checkMobileState.bind(this))
  }
} 