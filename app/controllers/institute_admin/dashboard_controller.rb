module InstituteAdmin
  class DashboardController < InstituteAdmin::BaseController
    def index
      @sections_count = current_institute.sections.count
      @participants_count = current_institute.participants.joins(:user).count
      @trainers_count = current_institute.trainers.joins(:user).count
      @questions_count = current_institute.questions.count
      @active_programs_count = current_institute.training_programs.where(status: :ongoing).count
      @completed_programs_count = current_institute.training_programs.where(status: :completed).count
      @individual_programs_count = current_institute.training_programs.where(program_type: :individual).count
      @section_programs_count = current_institute.training_programs.where(program_type: :section).count

      @recent_questions = current_institute.questions
        .order(created_at: :desc)
        .limit(5)

      @recent_question_sets = current_institute.question_sets
        .order(created_at: :desc)
        .limit(5)

      @recent_training_programs = current_institute.training_programs
        .includes(:trainer, :section, :participant)
        .order(created_at: :desc)
        .limit(5)
    end
  end
end
