module ParticipantPortal
  class TrainingProgramsController < ParticipantPortal::BaseController
    def index
      @training_programs = current_participant.all_training_programs
        .includes(:trainer, trainer: :user)
        .order(created_at: :desc)
    end

    def show
      @training_program = current_participant.all_training_programs
        .includes(:trainer, trainer: :user)
        .find(params[:id])
    end
  end
end
