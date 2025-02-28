module InstituteAdmin
  class AnalyticsController < InstituteAdmin::BaseController
    before_action :set_date_range, only: [ :index, :participant_performance, :section_performance, :assignment_analytics ]
    helper_method :calculate_assignment_completion_rate

    def index
      @sections = current_institute.sections.active
      @total_participants = current_institute.participants.count
      @total_assignments = current_institute.assignments.count
      @recent_assignments = current_institute.assignments.order(created_at: :desc).limit(5)

      # Overall completion rate
      @completion_rate = calculate_overall_completion_rate

      # Daily submission counts for chart
      @daily_submissions = AssignmentResponse
        .joins(:assignment)
        .where(assignments: { institute_id: current_institute.id })
        .where(response_date: @start_date..@end_date)
        .group("DATE(response_date)")
        .count

      # Section performance summary
      @section_performance = calculate_section_performance

      # Top performing participants
      @top_participants = find_top_participants(10)
    end

    def participant_performance
      @participant = current_institute.participants.find(params[:participant_id])
      @assignments = @participant.assignments

      # Participant's completion rate over time
      @completion_by_date = calculate_participant_completion_by_date(@participant)

      # Assignment completion details
      @assignment_details = calculate_participant_assignment_details(@participant)

      # Response patterns (time of day, day of week)
      @response_patterns = calculate_response_patterns(@participant)
    end

    def section_performance
      @section = current_institute.sections.find(params[:section_id])
      @participants = @section.participants.includes(:user)

      # Section completion rate
      @completion_rate = calculate_section_completion_rate(@section)

      # Participant comparison within section
      @participant_comparison = calculate_participant_comparison(@section)

      # Assignment completion by assignment
      @assignment_completion = calculate_section_assignment_completion(@section)
    end

    def assignment_analytics
      @assignment = current_institute.assignments.find(params[:assignment_id])

      # Overall completion rate
      @completion_rate = calculate_assignment_completion_rate(@assignment)

      # Daily completion trend
      @daily_completion = calculate_assignment_daily_completion(@assignment)

      # Question analysis
      @question_analysis = calculate_question_analysis(@assignment)

      # Section comparison (if applicable)
      @section_comparison = calculate_assignment_section_comparison(@assignment)
    end

    private

    def set_date_range
      @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.current
      @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : @end_date - 30.days
    rescue ArgumentError
      @end_date = Date.current
      @start_date = @end_date - 30.days
    end

    def calculate_overall_completion_rate
      total_responses = AssignmentResponse
        .joins(:assignment)
        .where(assignments: { institute_id: current_institute.id })
        .count

      total_possible = current_institute.assignments.sum do |assignment|
        assignment.questions.count * assignment.participants.count
      end

      total_possible > 0 ? (total_responses.to_f / total_possible * 100).round(2) : 0
    end

    def calculate_section_performance
      current_institute.sections.active.map do |section|
        completed_assignments = AssignmentResponse
          .joins(:assignment, :participant)
          .where(participants: { section_id: section.id })
          .where(assignments: { institute_id: current_institute.id })
          .select("DISTINCT assignment_id, participant_id, DATE(response_date)")
          .size

        total_assignments = Assignment
          .where(institute_id: current_institute.id)
          .joins(:sections)
          .where(sections: { id: section.id })
          .count * section.participants.count

        completion_rate = total_assignments > 0 ? (completed_assignments.to_f / total_assignments * 100).round(2) : 0

        {
          id: section.id,
          name: section.name,
          participant_count: section.participants.count,
          completion_rate: completion_rate
        }
      end
    end

    def find_top_participants(limit)
      participants = current_institute.participants.includes(:user)

      participants.map do |participant|
        completion_rate = calculate_participant_completion_rate(participant)

        {
          id: participant.id,
          name: participant.user.full_name,
          section: participant.section&.name,
          completion_rate: completion_rate
        }
      end.sort_by { |p| -p[:completion_rate] }.take(limit)
    end

    def calculate_participant_completion_rate(participant)
      assigned_count = Assignment.for_participant(participant).count
      completed_count = participant.assignment_responses
        .select("DISTINCT assignment_id, DATE(response_date)")
        .size

      assigned_count > 0 ? (completed_count.to_f / assigned_count * 100).round(2) : 0
    end

    def calculate_participant_completion_by_date(participant)
      participant.assignment_responses
        .where(response_date: @start_date..@end_date)
        .group("DATE(response_date)")
        .count
    end

    def calculate_participant_assignment_details(participant)
      participant.assignments.map do |assignment|
        completed_days = assignment.completed_days(participant)
        total_days = assignment.total_days

        {
          id: assignment.id,
          title: assignment.title,
          completed_days: completed_days,
          total_days: total_days,
          completion_percentage: assignment.completion_percentage(participant)
        }
      end
    end

    def calculate_response_patterns(participant)
      # Time of day patterns
      time_patterns = participant.assignment_responses
        .group("EXTRACT(HOUR FROM submitted_at)")
        .count

      # Day of week patterns
      day_patterns = participant.assignment_responses
        .group("EXTRACT(DOW FROM response_date)")
        .count

      {
        time_of_day: time_patterns,
        day_of_week: day_patterns
      }
    end

    def calculate_section_completion_rate(section)
      total_responses = AssignmentResponse
        .joins(:assignment, :participant)
        .where(participants: { section_id: section.id })
        .where(assignments: { institute_id: current_institute.id })
        .count

      total_possible = section.participants.sum do |participant|
        participant.assignments.sum { |a| a.questions.count }
      end

      total_possible > 0 ? (total_responses.to_f / total_possible * 100).round(2) : 0
    end

    def calculate_participant_comparison(section)
      section.participants.includes(:user).map do |participant|
        completion_rate = calculate_participant_completion_rate(participant)

        {
          id: participant.id,
          name: participant.user.full_name,
          completion_rate: completion_rate
        }
      end.sort_by { |p| -p[:completion_rate] }
    end

    def calculate_section_assignment_completion(section)
      assignments = Assignment
        .where(institute_id: current_institute.id)
        .joins(:sections)
        .where(sections: { id: section.id })

      assignments.map do |assignment|
        completed_count = AssignmentResponse
          .joins(:participant)
          .where(participants: { section_id: section.id })
          .where(assignment_id: assignment.id)
          .select("DISTINCT participant_id")
          .size

        total_count = section.participants.count

        {
          id: assignment.id,
          title: assignment.title,
          completed_count: completed_count,
          total_count: total_count,
          completion_percentage: total_count > 0 ? (completed_count.to_f / total_count * 100).round(2) : 0
        }
      end
    end

    def calculate_assignment_completion_rate(assignment)
      completed_count = assignment.assignment_responses
        .select("DISTINCT participant_id")
        .size

      total_count = assignment.participants.count

      total_count > 0 ? (completed_count.to_f / total_count * 100).round(2) : 0
    end

    def calculate_assignment_daily_completion(assignment)
      assignment.assignment_responses
        .where(response_date: @start_date..@end_date)
        .group("DATE(response_date)")
        .select("DATE(response_date) as date, COUNT(DISTINCT participant_id) as count")
        .map { |r| [ r.date, r.count ] }
        .to_h
    end

    def calculate_question_analysis(assignment)
      assignment.questions.map do |question|
        response_count = AssignmentResponse
          .where(assignment_id: assignment.id, question_id: question.id)
          .count

        # For multiple choice questions, calculate option distribution
        option_distribution = {}
        if [ "multiple_choice", "checkboxes", "dropdown" ].include?(question.question_type)
          responses = AssignmentResponse
            .where(assignment_id: assignment.id, question_id: question.id)

          question.options.each do |option|
            option_count = responses.where("selected_options @> ARRAY[?]::varchar[]", [ option.value ]).count
            option_distribution[option.value] = option_count
          end
        end

        {
          id: question.id,
          title: question.title,
          question_type: question.question_type,
          response_count: response_count,
          option_distribution: option_distribution
        }
      end
    end

    def calculate_assignment_section_comparison(assignment)
      return [] unless assignment.assignment_type == "section"

      assignment.sections.map do |section|
        completed_count = AssignmentResponse
          .joins(:participant)
          .where(participants: { section_id: section.id })
          .where(assignment_id: assignment.id)
          .select("DISTINCT participant_id")
          .size

        total_count = section.participants.count

        {
          id: section.id,
          name: section.name,
          completed_count: completed_count,
          total_count: total_count,
          completion_percentage: total_count > 0 ? (completed_count.to_f / total_count * 100).round(2) : 0
        }
      end
    end
  end
end
