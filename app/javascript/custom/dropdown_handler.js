// Dropdown handler for Turbo-enabled applications

document.addEventListener('DOMContentLoaded', initializeDropdowns);
document.addEventListener('turbo:load', initializeDropdowns);
document.addEventListener('turbo:render', initializeDropdowns);
document.addEventListener('turbo:frame-render', initializeDropdowns);

// Function to initialize all dropdowns
function initializeDropdowns() {
  if (typeof bootstrap === 'undefined') {
    console.warn('Bootstrap is not loaded. Dropdowns will not work.');
    return;
  }
  
  // Get all dropdown toggles
  const dropdownToggles = document.querySelectorAll('[data-bs-toggle="dropdown"]');
  
  // Initialize each dropdown
  dropdownToggles.forEach(toggle => {
    // Dispose existing instance if any
    const existingDropdown = bootstrap.Dropdown.getInstance(toggle);
    if (existingDropdown) {
      existingDropdown.dispose();
    }
    
    // Create new dropdown instance
    new bootstrap.Dropdown(toggle);
    
    // Add click handler to ensure dropdown works
    if (!toggle.hasAttribute('data-dropdown-initialized')) {
      toggle.setAttribute('data-dropdown-initialized', 'true');
      
      toggle.addEventListener('click', function(event) {
        event.stopPropagation();
        
        const dropdown = bootstrap.Dropdown.getInstance(this);
        if (dropdown) {
          dropdown.toggle();
        } else {
          new bootstrap.Dropdown(this).toggle();
        }
      });
    }
  });
}

// Global click handler for dropdown toggles
document.addEventListener('click', function(event) {
  const toggle = event.target.closest('[data-bs-toggle="dropdown"]');
  if (!toggle) return;
  
  // Prevent default behavior
  event.preventDefault();
  event.stopPropagation();
  
  // Get or create dropdown instance
  let dropdown = bootstrap.Dropdown.getInstance(toggle);
  if (!dropdown) {
    dropdown = new bootstrap.Dropdown(toggle);
  }
  
  // Toggle the dropdown
  dropdown.toggle();
}, true); 