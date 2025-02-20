module ParticipantPortal
  class DashboardController < ParticipantPortal::BaseController
    def index
      @training_programs = current_participant.all_training_programs
        .includes(:trainer)
        .order(created_at: :desc)
    end
  end
end
