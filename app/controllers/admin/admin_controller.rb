module Admin
  class AdminController < Admin::BaseController
    before_action :clear_impersonation_session

    def dashboard
      # Basic Statistics
      @institutes_count = Institute.count
      @institute_admins_count = User.institute_admin.count

      # Get all institutes with their statistics
      @institutes = Institute.all.map do |institute|
        {
          id: institute.id,
          name: institute.name,
          stats: {
            programs: {
              total: institute.training_programs.count,
              active: institute.training_programs.where(status: :ongoing).count,
              completed: institute.training_programs.where(status: :completed).count
            },
            participants: {
              total: institute.participants.count,
              active: institute.participants.joins(:user).where(users: { active: true }).count
            },
            sections: {
              total: institute.sections.count,
              active: institute.sections.active.count
            },
            assignments: {
              total: institute.assignments.count,
              active: institute.assignments.active.count
            },
            questions: institute.questions.count,
            question_sets: institute.question_sets.count,
            feedbacks: {
              count: institute.training_programs.joins(:training_program_feedbacks).count
            }
          }
        }
      end

      # Data for charts
      @institution_stats = {
        labels: @institutes.map { |i| i[:name] },
        participants: @institutes.map { |i| i[:stats][:participants][:total] },
        active_participants: @institutes.map { |i| i[:stats][:participants][:active] },
        programs: @institutes.map { |i| i[:stats][:programs][:total] },
        active_programs: @institutes.map { |i| i[:stats][:programs][:active] },
        sections: @institutes.map { |i| i[:stats][:sections][:total] },
        assignments: @institutes.map { |i| i[:stats][:assignments][:total] },
        avg_ratings: @institutes.map { |i| i[:stats][:feedbacks][:average_rating] }
      }

      # Recent Data
      @recent_institutes = Institute.order(created_at: :desc).limit(5)
      @recent_programs = TrainingProgram.includes(:institute, :trainer)
                                      .order(created_at: :desc)
                                      .limit(5)
      @recent_feedbacks = TrainingProgramFeedback.includes(:training_program, :participant)
                                               .order(created_at: :desc)
                                               .limit(5)
    end

    private

    def clear_impersonation_session
      session.delete(:admin_institute_id)
      session.delete(:admin_return_to)
    end
  end
end
