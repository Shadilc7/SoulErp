module ParticipantPortal
  class AssignmentsController < ParticipantPortal::BaseController
    before_action :set_assignment, except: [ :index ]
    before_action :check_date_availability, only: [ :take_assignment, :submit ]

    def index
      @selected_date = parse_date(params[:date])
      @assignments = Assignment.for_participant(current_participant)
        .for_date(@selected_date)
        .order(created_at: :desc)

      respond_to do |format|
        format.html { redirect_to participant_portal_root_path }
        format.turbo_stream {
          render turbo_stream: turbo_stream.update("assignment_content",
            partial: "participant_portal/dashboard/daily_assignments",
            locals: {
              assignments: @assignments,
              selected_date: @selected_date
            }
          )
        }
      end
    end

    def show
      @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.current

      @individual_questions = @assignment.questions.order(:created_at)
      @question_set_questions = @assignment.question_sets.includes(:questions)
        .flat_map(&:questions)

      respond_to do |format|
        format.html # renders show.html.erb
        format.turbo_stream {
          render turbo_stream: turbo_stream.update("main_content",
            template: "participant_portal/assignments/show"
          )
        }
      end
    end

    def take_assignment
      @selected_date = parse_date(params[:date])
      @questions = @assignment.all_questions
    end

    def submit
      @selected_date = parse_date(params[:date])
      @responses = params[:responses].to_unsafe_h

      # First check if already submitted
      if @assignment.answered_by_on_date?(current_participant, @selected_date)
        flash[:alert] = "You have already submitted this assignment for #{@selected_date.strftime('%B %d, %Y')}"
        redirect_to participant_portal_root_path
        return
      end

      begin
        ActiveRecord::Base.transaction do
          all_saved = true
          saved_response_ids = []

          @responses.each do |question_id, response_data|
            question = Question.find(question_id)
            response = current_participant.assignment_responses.find_or_initialize_by(
              assignment: @assignment,
              question_id: question_id,
              response_date: @selected_date
            )

            # Handle different question types
            case question.question_type
            when 'checkboxes'
              response.selected_options = response_data[:selected_options].presence || []
              response.answer = nil
            when 'multiple_choice', 'dropdown'
              response.answer = response_data[:answer]
              response.selected_options = [response_data[:answer]].compact
            else
              response.answer = response_data[:answer]
              response.selected_options = []
            end

            response.submitted_at = Time.current

            if response.save
              saved_response_ids << response.id
            else
              all_saved = false
              break
            end
          end

          if all_saved
            AssignmentResponseLog.log_responses(
              participant: current_participant,
              assignment: @assignment,
              response_ids: saved_response_ids,
              response_date: @selected_date
            )

            redirect_to participant_portal_root_path(date: @selected_date),
                        notice: "Assignment submitted successfully!"
          else
            raise ActiveRecord::Rollback
          end
        end
      rescue => e
        flash.now[:alert] = "Error submitting assignment. Please try again."
        @questions = @assignment.all_questions
        render :take_assignment, status: :unprocessable_entity
      end
    end

    private

    def set_assignment
      @assignment = Assignment.find(params[:id])
    end

    def check_date_availability
      @selected_date = parse_date(params[:date])

      if @assignment.answered_by_on_date?(current_participant, @selected_date)
        flash[:error] = "You have already submitted this assignment for #{@selected_date.strftime('%B %d, %Y')}"
        redirect_to participant_portal_root_path
        return
      end

      unless @assignment.available_for_date?(current_participant, @selected_date)
        flash[:error] = "This assignment is not available for the selected date"
        redirect_to participant_portal_root_path
      end
    end

    def parse_date(date_param)
      return Date.current unless date_param.present?
      Date.parse(date_param)
    rescue ArgumentError
      Date.current
    end
  end
end
