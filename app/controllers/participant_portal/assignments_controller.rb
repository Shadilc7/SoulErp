module ParticipantPortal
  class AssignmentsController < ParticipantPortal::BaseController
    before_action :set_assignment, except: [ :index ]
    before_action :check_date_availability, only: [ :take_assignment, :submit ]

    def index
      @selected_date = parse_date(params[:date])

      # Add debugging
      Rails.logger.debug "Selected Date: #{@selected_date}"

      @assignments = Assignment.for_participant(current_participant)
        .for_date(@selected_date)
        .order(created_at: :desc)

      # Add debugging
      Rails.logger.debug "Found Assignments: #{@assignments.to_sql}"
      Rails.logger.debug "Assignment Count: #{@assignments.count}"

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

      # Add debugging
      Rails.logger.debug "Questions loaded: #{@questions.count}"
      @questions.each do |q|
        Rails.logger.debug "Question #{q.id}: #{q.question_type} - #{q.title}"
        Rails.logger.debug "Options: #{q.options.pluck(:value)}" if q.requires_options?
      end
    end

    def submit
      @selected_date = parse_date(params[:date])

      ActiveRecord::Base.transaction do
        params[:responses].each do |question_id, response_data|
          @response = AssignmentResponse.new(
            assignment: @assignment,
            participant: current_participant,
            question_id: question_id,
            created_at: @selected_date
          )

          if response_data[:selected_options].is_a?(Array)
            @response.selected_options = response_data[:selected_options]
          elsif response_data[:selected_options].present?
            @response.selected_options = [ response_data[:selected_options] ]
          end

          @response.answer = response_data[:answer] if response_data[:answer].present?

          unless @response.save
            raise ActiveRecord::Rollback
          end
        end

        flash[:success] = "Assignment completed successfully!"
        redirect_to participant_portal_root_path
      end
    rescue ActiveRecord::Rollback
      flash[:error] = "Failed to submit assignment. Please try again."
      render :take_assignment
    end

    private

    def set_assignment
      @assignment = Assignment.find(params[:id])
    end

    def check_date_availability
      @selected_date = parse_date(params[:date])

      unless @assignment.available_for_date?(current_participant, @selected_date)
        flash[:error] = "This assignment is not available for the selected date"
        redirect_to participant_portal_root_path
      end
    end

    def parse_date(date_param)
      return Date.current unless date_param.present?

      begin
        date = Date.parse(date_param)
        # Ensure we're working with dates in the application's timezone
        date.in_time_zone.to_date
      rescue ArgumentError
        Date.current
      end
    end
  end
end
