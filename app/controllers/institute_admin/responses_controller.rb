module InstituteAdmin
  class ResponsesController < InstituteAdmin::BaseController
    before_action :set_date, only: [ :index ]
    before_action :set_section, only: [ :index ], if: -> { params[:section_id].present? }
    before_action :set_participant, only: [ :index ], if: -> { params[:participant_id].present? && params[:section_id].present? }
    before_action :set_assignment, only: [ :index ], if: -> { params[:assignment_id].present? }

    def index
      # Always load sections
      @sections = current_institute.sections.active
      
      # Ensure participants are loaded for the section if it exists
      if @section
        @participants = @section.participants
                              .includes(:user)
                              .where(status: :active)
                              .where(participant_type: 'student')
        Rails.logger.debug "Found #{@participants.count} participants for section #{@section.id}"
      end
      
      # Log form submission details
      if params[:commit].present?
        Rails.logger.debug "Form submitted with date: #{@selected_date}, section_id: #{params[:section_id]}, participant_id: #{params[:participant_id]}"
      end
      
      # Only proceed with fetching assignments if the form was submitted
      if params[:commit].present? && @participant && @selected_date
        @assignments = @participant.assignments_for_date(@selected_date)
        Rails.logger.debug "Found #{@assignments.count} assignments for participant #{@participant.id} on date #{@selected_date}"

        # If assignment_id is provided, fetch responses
        if @assignment
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
      begin
        @participant = @section.participants.find(params[:participant_id])
      rescue ActiveRecord::RecordNotFound
        flash.now[:alert] = "Participant not found."
        @participant = nil
      end
    end

    def set_assignment
      begin
        @assignment = Assignment.find(params[:assignment_id])
      rescue ActiveRecord::RecordNotFound
        flash.now[:alert] = "Assignment not found."
        @assignment = nil
      end
    end
  end
end
