module InstituteAdmin
  class ReportsController < InstituteAdmin::BaseController
    def index
      @date_range = params[:date_range]
      @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.current
      @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.current
      @section_id = params[:section_id]
      @report_type = params[:report_type] || 'assignments'

      if params[:commit].present? && params[:submission_status].present?
        case @report_type
        when 'assignments'
          fetch_assignment_reports
        when 'feedbacks'
          fetch_feedback_reports
        end
      end

      respond_to do |format|
        format.html
        format.csv { send_data generate_csv, filename: "#{@report_type}_report_#{Date.current}.csv" }
      end
    end

    private

    def fetch_assignment_reports
      base_query = AssignmentResponseLog.includes(:participant, :assignment, participant: :section)
                                      .where(institute: current_institute)
      
      # Apply date filters
      base_query = case @date_range
                  when 'today'
                    base_query.where(response_date: Date.current)
                  when 'yesterday'
                    base_query.where(response_date: Date.yesterday)
                  when 'last_7_days'
                    base_query.where(response_date: 7.days.ago.beginning_of_day..Time.current)
                  when 'this_month'
                    base_query.where(response_date: Time.current.beginning_of_month..Time.current)
                  when 'custom'
                    base_query.where(response_date: @start_date.beginning_of_day..@end_date.end_of_day)
                  else
                    base_query.where(response_date: Date.current)
                  end

      # Apply section filter if selected
      if @section_id.present? && @section_id != 'all'
        base_query = base_query.joins(participant: :section)
                              .where(sections: { id: @section_id })
      end

      @submitted_logs = base_query.order(response_date: :desc)

      # Preload assignment responses for performance
      @assignment_responses = AssignmentResponse.where(id: @submitted_logs.map(&:assignment_response_ids).flatten).index_by(&:id)

      # Get all participants who should have submitted
      all_participants = if @section_id.present? && @section_id != 'all'
                         current_institute.participants.includes(:section).where(section_id: @section_id)
                       else
                         current_institute.participants.includes(:section)
                       end

      # Get participants who haven't submitted
      submitted_participant_ids = @submitted_logs.pluck(:participant_id).uniq
      @not_submitted_participants = all_participants.where.not(id: submitted_participant_ids)

      # Clear the data that's not needed based on submission status
      if params[:submission_status] == 'submitted'
        @not_submitted_participants = []
      else
        @submitted_logs = []
      end
    end

    def fetch_feedback_reports
      base_query = TrainingProgramFeedback.includes(:participant, :training_program, participant: :section)
                                        .where(training_programs: { institute_id: current_institute.id })

      # Apply date filters
      base_query = case @date_range
                  when 'today'
                    base_query.where(created_at: Date.current.all_day)
                  when 'yesterday'
                    base_query.where(created_at: Date.yesterday.all_day)
                  when 'last_7_days'
                    base_query.where(created_at: 7.days.ago.beginning_of_day..Time.current)
                  when 'this_month'
                    base_query.where(created_at: Time.current.beginning_of_month..Time.current)
                  when 'custom'
                    base_query.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                  else
                    base_query.where(created_at: Date.current.all_day)
                  end

      # Apply section filter if selected
      if @section_id.present? && @section_id != 'all'
        base_query = base_query.joins(participant: :section)
                              .where(sections: { id: @section_id })
      end

      @submitted_feedbacks = base_query.order(created_at: :desc)

      # Get all participants who should have submitted feedback
      all_participants = if @section_id.present? && @section_id != 'all'
                         current_institute.participants.includes(:section).where(section_id: @section_id)
                       else
                         current_institute.participants.includes(:section)
                       end

      # Get participants who haven't submitted feedback
      submitted_participant_ids = @submitted_feedbacks.pluck(:participant_id).uniq
      @not_submitted_participants = all_participants.where.not(id: submitted_participant_ids)

      # Clear the data that's not needed based on submission status
      if params[:submission_status] == 'submitted'
        @not_submitted_participants = []
      else
        @submitted_feedbacks = []
      end
    end

    def generate_csv
      require 'csv'

      CSV.generate(headers: true) do |csv|
        if @report_type == 'assignments'
          if params[:submission_status] == 'submitted'
            # Generate submitted assignments CSV
            csv << ['Date', 'Participant', 'Section', 'Assignment', 'Responses', 'Score']
            @submitted_logs.each do |log|
              responses = log.assignment_response_ids.map { |id| @assignment_responses[id] }.compact
              total_questions = responses.count
              score = if total_questions > 0
                gradable_responses = responses.reject { |r| r.question.rating? }
                if gradable_responses.any?
                  correct_answers = gradable_responses.count(&:correct?)
                  score_percentage = (correct_answers.to_f / gradable_responses.count * 100).round(1)
                  "#{score_percentage}%"
                else
                  'No Score'
                end
              else
                'Pending'
              end
              
              csv << [
                log.response_date.strftime("%B %d, %Y"),
                log.participant.full_name,
                log.participant.section.name,
                log.assignment.title,
                log.assignment_response_ids.size,
                score
              ]
            end
          else
            # Generate not submitted assignments CSV
            csv << ['Participant', 'Section', 'Email']
            @not_submitted_participants.each do |participant|
              csv << [
                participant.full_name,
                participant.section.name,
                participant.email
              ]
            end
          end
        else # feedbacks
          if params[:submission_status] == 'submitted'
            # Generate submitted feedbacks CSV
            csv << ['Date', 'Participant', 'Section', 'Training Program', 'Rating', 'Content']
            @submitted_feedbacks.each do |feedback|
              csv << [
                feedback.created_at.strftime("%B %d, %Y"),
                feedback.participant.full_name,
                feedback.participant.section.name,
                feedback.training_program.title,
                feedback.rating,
                feedback.content
              ]
            end
          else
            # Generate not submitted feedbacks CSV
            csv << ['Participant', 'Section', 'Email']
            @not_submitted_participants.each do |participant|
              csv << [
                participant.full_name,
                participant.section.name,
                participant.email
              ]
            end
          end
        end
      end
    end
  end
end 