module InstituteAdmin
  class ResponsesController < InstituteAdmin::BaseController
    before_action :set_date, only: [ :index ]
    before_action :set_section, only: [ :index ], if: -> { params[:section_id].present? }
    before_action :set_participant, only: [ :index ], if: -> { params[:participant_id].present? }
    before_action :set_assignment, only: [ :index ], if: -> { params[:assignment_id].present? }

    def index
      @sections = current_institute.sections.active if @selected_date

      if @section
        @participants = @section.participants.includes(:user)
      end

      if @participant
        @assignments = @participant.assignments_for_date(@selected_date)
      end

      if @assignment && @participant && @selected_date
        @responses = @assignment.assignment_responses
          .where(participant: @participant)
          .where(response_date: @selected_date)
          .includes(:question)
          .order("questions.title")

        # Let's log some debug info
        Rails.logger.debug "Selected Date: #{@selected_date}"
        Rails.logger.debug "Assignment ID: #{@assignment.id}"
        Rails.logger.debug "Participant ID: #{@participant.id}"
        Rails.logger.debug "Response Count: #{@responses.count}"
        Rails.logger.debug "SQL Query: #{@responses.to_sql}"
      end
    end

    def show
      @response = if @assignment
        @assignment.assignment_responses.find(params[:id])
      else
        AssignmentResponse.joins(:participant)
          .where(participants: { institute_id: current_institute.id })
          .find(params[:id])
      end
    end

    private

    def set_date
      @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    rescue ArgumentError
      @selected_date = Date.current
    end

    def set_section
      @section = current_institute.sections.find(params[:section_id])
    end

    def set_participant
      @participant = @section.participants.find(params[:participant_id])
    end

    def set_assignment
      @assignment = Assignment.find(params[:assignment_id])
    end
  end
end
