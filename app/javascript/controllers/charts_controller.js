import { Controller } from "@hotwired/stimulus"
// No Chart.js import here! Use global Chart from CDN

export default class extends Controller {
  static targets = ["participants", "programs", "resources", "ratings"]
  static values = {
    stats: Object
  }

  connect() {
    this.colors = {
      primary: '#0d6efd',
      success: '#198754',
      info: '#0dcaf0',
      warning: '#ffc107'
    }
    this.initializeCharts()
  }

  initializeCharts() {
    if (this.hasParticipantsTarget) {
      this.initParticipantsChart()
    }
    if (this.hasProgramsTarget) {
      this.initProgramsChart()
    }
    if (this.hasResourcesTarget) {
      this.initResourcesChart()
    }
    if (this.hasRatingsTarget) {
      this.initRatingsChart()
    }
  }

  initParticipantsChart() {
    const stats = this.statsValue
    new Chart(this.participantsTarget, {
      type: 'bar',
      data: {
        labels: stats.labels,
        datasets: [{
          label: 'Total Participants',
          data: stats.participants,
          backgroundColor: this.colors.primary
        }, {
          label: 'Active Participants',
          data: stats.active_participants,
          backgroundColor: this.colors.success
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { position: 'bottom' }
        }
      }
    })
  }

  initProgramsChart() {
    const stats = this.statsValue
    new Chart(this.programsTarget, {
      type: 'bar',
      data: {
        labels: stats.labels,
        datasets: [{
          label: 'Total Programs',
          data: stats.programs,
          backgroundColor: this.colors.info
        }, {
          label: 'Active Programs',
          data: stats.active_programs,
          backgroundColor: this.colors.success
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { position: 'bottom' }
        }
      }
    })
  }

  initResourcesChart() {
    const stats = this.statsValue
    new Chart(this.resourcesTarget, {
      type: 'radar',
      data: {
        labels: stats.labels,
        datasets: [{
          label: 'Sections',
          data: stats.sections,
          borderColor: this.colors.primary,
          backgroundColor: `${this.colors.primary}33`
        }, {
          label: 'Assignments',
          data: stats.assignments,
          borderColor: this.colors.success,
          backgroundColor: `${this.colors.success}33`
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { position: 'bottom' }
        }
      }
    })
  }

  initRatingsChart() {
    const stats = this.statsValue
    new Chart(this.ratingsTarget, {
      type: 'line',
      data: {
        labels: stats.labels,
        datasets: [{
          label: 'Average Rating',
          data: stats.avg_ratings,
          borderColor: this.colors.warning,
          backgroundColor: `${this.colors.warning}33`,
          fill: true,
          tension: 0.4
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { position: 'bottom' }
        },
        scales: {
          y: {
            min: 0,
            max: 5,
            ticks: {
              stepSize: 1
            }
          }
        }
      }
    })
  }
}