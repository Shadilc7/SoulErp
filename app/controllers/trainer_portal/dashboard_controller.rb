module TrainerPortal
  class DashboardController < TrainerPortal::BaseController
    def index
      @training_programs = current_trainer.training_programs
        .includes(:section, participant: :user)
        .order(created_at: :desc)
        .limit(5)

      @active_programs = current_trainer.training_programs
        .where(status: :ongoing)
        .includes(:section, participant: :user)
        .order(created_at: :desc)

      @active_programs_count = current_trainer.training_programs
        .where(status: :ongoing)
        .count

      @completed_programs_count = current_trainer.training_programs
        .where(status: :completed)
        .count

      @individual_programs_count = current_trainer.training_programs
        .where(program_type: :individual)
        .count

      @section_programs_count = current_trainer.training_programs
        .where(program_type: :section)
        .count
    end
  end
end
