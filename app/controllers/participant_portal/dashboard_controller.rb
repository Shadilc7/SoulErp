module ParticipantPortal
  class DashboardController < ParticipantPortal::BaseController
    def index
      @training_programs = current_participant.all_training_programs
        .includes(:trainer)
        .order(created_at: :desc)

      @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.current

      # Get assignments for the selected date
      @assignments = Assignment.for_participant(current_participant)
        .where("? BETWEEN start_date AND end_date", @selected_date)
        .order(created_at: :desc)
    end
  end
end
