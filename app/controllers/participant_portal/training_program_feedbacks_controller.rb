module ParticipantPortal
  class TrainingProgramFeedbacksController < ParticipantPortal::BaseController
    before_action :set_training_program

    def new
      @feedback = @training_program.build_feedback(participant: current_participant)
    end

    def create
      @feedback = @training_program.build_feedback(feedback_params)
      @feedback.participant = current_participant

      if @feedback.save
        redirect_to participant_portal_root_path,
          notice: "Thank you! Your feedback has been submitted successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def set_training_program
      @training_program = current_participant.all_training_programs.find(params[:training_program_id])
    end

    def feedback_params
      params.require(:training_program_feedback).permit(:content, :rating)
    end
  end
end
