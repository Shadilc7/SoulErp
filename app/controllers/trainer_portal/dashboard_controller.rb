module TrainerPortal
  class DashboardController < BaseController
    def index
      @training_programs = current_trainer.training_programs
        .includes(:participant)
        .order(created_at: :desc)
    end
  end
end
