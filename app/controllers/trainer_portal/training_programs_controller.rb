module TrainerPortal
  class TrainingProgramsController < BaseController
    before_action :set_training_program, only: [:show, :update_progress, :mark_completed]

    def index
      @training_programs = current_trainer.training_programs
        .includes(:participant)
        .order(created_at: :desc)

      @training_programs = case params[:status]
      when 'ongoing'
        @training_programs.ongoing
      when 'completed'
        @training_programs.completed
      else
        @training_programs
      end
    end

    def show
    end

    def update_progress
      if @training_program.update(progress_params)
        flash[:notice] = "Progress updated successfully"
      else
        flash[:alert] = "Failed to update progress"
      end
      redirect_to trainer_portal_training_program_path(@training_program)
    end

    def mark_completed
      if @training_program.update(status: :completed)
        flash[:notice] = "Training program marked as completed"
      else
        flash[:alert] = "Failed to mark program as completed"
      end
      redirect_to trainer_portal_training_program_path(@training_program)
    end

    private

    def set_training_program
      @training_program = current_trainer.training_programs.find(params[:id])
    end

    def progress_params
      params.require(:training_program).permit(:progress)
    end
  end
end
