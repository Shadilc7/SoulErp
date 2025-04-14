import { Controller } from "@hotwired/stimulus"

/**
 * Sidebar Controller
 * 
 * Handles sidebar behavior including:
 * - Mobile sidebar toggle
 * - Submenu toggling
 * - Scroll position preservation
 */
export default class extends Controller {
  static targets = ["content", "backdrop"]

  connect() {
    // Handle initial mobile state
    this.checkMobileState()
    
    // Listen for window resize
    window.addEventListener('resize', this.checkMobileState.bind(this))
    
    // Add event listeners to sidebar links to preserve scroll position
    this.setupSidebarLinkListeners()
    
    // Add direct event listeners to all submenu toggles to ensure they work
    this.initializeSubmenuToggles()
  }
  
  /**
   * Initialize direct event listeners for submenu toggles
   * This approach bypasses Bootstrap's collapse behavior for more reliable operation
   */
  initializeSubmenuToggles() {
    // Add click handlers directly to ensure they work with or without Bootstrap
    const submenuToggles = document.querySelectorAll('[data-custom-toggle="true"]')
    submenuToggles.forEach(toggle => {
      // Remove any existing listeners first
      toggle.removeEventListener('click', this.handleSubmenuToggleClick)
      // Add our direct handler
      toggle.addEventListener('click', this.handleSubmenuToggleClick)
    })
  }
  
  /**
   * Handle submenu toggle clicks
   * Uses direct DOM manipulation instead of Bootstrap's Collapse API
   */
  handleSubmenuToggleClick = (event) => {
    event.preventDefault()
    event.stopPropagation()
    
    const toggle = event.currentTarget
    const targetId = toggle.getAttribute('href')
    const target = document.querySelector(targetId)
    
    if (!target) return
    
    // Get current state
    const isExpanded = toggle.getAttribute('aria-expanded') === 'true'
    
    // Toggle all states directly
    if (isExpanded) {
      // Collapse the submenu
      toggle.setAttribute('aria-expanded', 'false')
      toggle.classList.remove('active-parent')
      target.classList.remove('show')
      localStorage.removeItem('openSubmenu')
    } else {
      // Expand the submenu
      toggle.setAttribute('aria-expanded', 'true')
      toggle.classList.add('active-parent')
      target.classList.add('show')
      localStorage.setItem('openSubmenu', targetId.substring(1))
    }
  }

  /**
   * Toggle mobile sidebar visibility
   */
  toggle() {
    const sidebar = document.getElementById('sidebar')
    if (sidebar) {
      sidebar.classList.toggle('show')
      this.backdropTarget.classList.toggle('show')
      document.body.style.overflow = sidebar.classList.contains('show') ? 'hidden' : ''
    }
  }

  /**
   * Hide mobile sidebar
   */
  hide() {
    const sidebar = document.getElementById('sidebar')
    if (sidebar) {
      sidebar.classList.remove('show')
      this.backdropTarget.classList.remove('show')
      document.body.style.overflow = ''
    }
  }

  /**
   * Check if viewport is mobile sized and update sidebar state
   */
  checkMobileState() {
    if (window.innerWidth >= 992) {
      this.hide()
    }
  }
  
  /**
   * Setup scroll position persistence for sidebar
   */
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

  /**
   * Stimulus action method for toggling submenu
   * This delegates to our custom handler
   */
  toggleSubmenu(event) {
    // Just call our direct handler
    this.handleSubmenuToggleClick(event)
  }

  disconnect() {
    window.removeEventListener('resize', this.checkMobileState.bind(this))
    
    // Remove our custom event listeners
    const submenuToggles = document.querySelectorAll('[data-custom-toggle="true"]')
    submenuToggles.forEach(toggle => {
      toggle.removeEventListener('click', this.handleSubmenuToggleClick)
    })
  }
} 