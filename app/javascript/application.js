// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "custom/dropdown_handler"
import * as bootstrap from "bootstrap"

// Make bootstrap globally available
window.bootstrap = bootstrap;

// Track initialization to prevent duplicate initializations
let pageInitialized = false;

/**
 * Utility function to check if current URL belongs to a section
 */
function isUrlInSection(patterns) {
  const currentPath = window.location.pathname;
  return patterns.some(pattern => currentPath.includes(pattern));
}

/**
 * Initialize submenu states based on current page and saved state
 */
function initializeSubmenuStates() {
  try {
    // Check which section the current page belongs to
    const isTrainingSection = isUrlInSection([
      '/institute_admin/trainers',
      '/institute_admin/training_programs',
      '/institute_admin/attendances'
    ]);
    
    const isAssessmentsSection = isUrlInSection([
      '/institute_admin/questions',
      '/institute_admin/assignments',
      '/institute_admin/responses'
    ]);
    
    const openSubmenuId = localStorage.getItem('openSubmenu');
    
    // Handle Training submenu
    const trainingSubmenu = document.getElementById('trainingSubmenu');
    const trainingToggle = document.querySelector('a[href="#trainingSubmenu"]');
    
    if (trainingSubmenu && trainingToggle) {
      if (isTrainingSection) {
        // Open training submenu for training pages
        trainingSubmenu.classList.add('show');
        trainingToggle.setAttribute('aria-expanded', 'true');
        trainingToggle.classList.add('active-parent');
      } else if (openSubmenuId !== 'trainingSubmenu') {
        // Close unless specifically opened by user
        trainingSubmenu.classList.remove('show');
        trainingToggle.setAttribute('aria-expanded', 'false');
        trainingToggle.classList.remove('active-parent');
      }
    }
    
    // Handle Assessments submenu
    const assessmentsSubmenu = document.getElementById('assessmentsSubmenu');
    const assessmentsToggle = document.querySelector('a[href="#assessmentsSubmenu"]');
    
    if (assessmentsSubmenu && assessmentsToggle) {
      if (isAssessmentsSection) {
        // Open assessments submenu for assessment pages
        assessmentsSubmenu.classList.add('show');
        assessmentsToggle.setAttribute('aria-expanded', 'true');
        assessmentsToggle.classList.add('active-parent');
      } else if (openSubmenuId !== 'assessmentsSubmenu') {
        // Close unless specifically opened by user
        assessmentsSubmenu.classList.remove('show');
        assessmentsToggle.setAttribute('aria-expanded', 'false');
        assessmentsToggle.classList.remove('active-parent');
      }
    }
    
    // User explicitly saved submenu state overrides default behavior
    if (openSubmenuId) {
      const submenu = document.getElementById(openSubmenuId);
      const toggle = document.querySelector(`a[href="#${openSubmenuId}"]`);
      
      if (submenu && toggle) {
        submenu.classList.add('show');
        toggle.setAttribute('aria-expanded', 'true');
        toggle.classList.add('active-parent');
      }
    }
  } catch (error) {
    console.error('Error initializing submenu states:', error);
  }
}

/**
 * Initialize Bootstrap components
 */
function initializeBootstrapComponents() {
  if (pageInitialized) return;
  
  try {
    // Dropdowns
    const dropdownElementList = document.querySelectorAll('[data-bs-toggle="dropdown"]');
    dropdownElementList.forEach(el => {
      if (!bootstrap.Dropdown.getInstance(el)) {
        new bootstrap.Dropdown(el);
      }
    });
    
    // Tooltips
    const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]');
    tooltipTriggerList.forEach(el => {
      if (!bootstrap.Tooltip.getInstance(el)) {
        new bootstrap.Tooltip(el);
      }
    });
    
    // Popovers
    const popoverTriggerList = document.querySelectorAll('[data-bs-toggle="popover"]');
    popoverTriggerList.forEach(el => {
      if (!bootstrap.Popover.getInstance(el)) {
        new bootstrap.Popover(el);
      }
    });
    
    pageInitialized = true;
  } catch (error) {
    console.error('Error initializing Bootstrap components:', error);
  }
}

/**
 * Clean up Bootstrap component instances before navigation
 */
function cleanupBootstrapComponents() {
  try {
    // Clean up tooltips
    const tooltips = document.querySelectorAll('[data-bs-toggle="tooltip"]');
    tooltips.forEach(element => {
      const tooltip = bootstrap.Tooltip.getInstance(element);
      if (tooltip) tooltip.dispose();
    });
    
    // Clean up popovers
    const popovers = document.querySelectorAll('[data-bs-toggle="popover"]');
    popovers.forEach(element => {
      const popover = bootstrap.Popover.getInstance(element);
      if (popover) popover.dispose();
    });
    
    // Clean up dropdowns
    const dropdowns = document.querySelectorAll('[data-bs-toggle="dropdown"]');
    dropdowns.forEach(element => {
      const dropdown = bootstrap.Dropdown.getInstance(element);
      if (dropdown) dropdown.dispose();
    });
    
    // We don't dispose collapse instances as they conflict with our custom submenu handling
  } catch (error) {
    console.error('Error cleaning up Bootstrap components:', error);
  }
}

/**
 * Setup dynamic option fields for question forms
 */
function setupDynamicOptionFields() {
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

  // Handle option removal
  document.addEventListener('click', (e) => {
    if (e.target.closest('.remove-option')) {
      e.target.closest('.input-group').remove()
    }
  })
}

// Initialize components when Turbo loads a page
document.addEventListener('turbo:load', () => {
  console.log('Turbo load: Initializing components');
  
  // Use requestAnimationFrame to batch DOM operations and reduce reflows
  requestAnimationFrame(() => {
    initializeSubmenuStates();
    initializeBootstrapComponents();
    setupDynamicOptionFields();
    console.log('Components initialized');
  });
});

// Reset initialization flag when starting navigation
document.addEventListener('turbo:visit', () => {
  pageInitialized = false;
});

// Clean up components before navigation
document.addEventListener('turbo:before-render', () => {
  console.log('Cleaning up components before navigation');
  cleanupBootstrapComponents();
});
