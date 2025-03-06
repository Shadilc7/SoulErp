module InstituteAdmin
  class TrainingProgramFeedbacksController < InstituteAdmin::BaseController
    before_action :set_training_program, only: [:index]

    def index
      @feedbacks = @training_program.training_program_feedbacks.includes(:participant => :user)
    end

    private

    def set_training_program
      @training_program = current_institute.training_programs.find(params[:training_program_id])
    end
  end
end 