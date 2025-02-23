module Participant
  class AssignmentsController < Participant::BaseController
    before_action :set_assignment, only: [ :show, :submit_response ]

    def index
      @assignments = current_participant.assignments
        .or(Assignment.joins(:assignment_sections)
          .where(assignment_sections: { section_id: current_participant.section_id }))
        .current
        .order(end_date: :asc)

      @upcoming_assignments = current_participant.assignments
        .or(Assignment.joins(:assignment_sections)
          .where(assignment_sections: { section_id: current_participant.section_id }))
        .upcoming
        .order(start_date: :asc)

      @past_assignments = current_participant.assignments
        .or(Assignment.joins(:assignment_sections)
          .where(assignment_sections: { section_id: current_participant.section_id }))
        .past
        .order(end_date: :desc)
    end

    def show
      @responses = current_participant.assignment_responses
        .where(assignment: @assignment)
        .includes(:question)
    end

    def submit_response
      @response = current_participant.assignment_responses.find_or_initialize_by(
        assignment: @assignment,
        question_id: params[:question_id]
      )

      @response.answer = params[:answer]
      @response.selected_options = params[:selected_options]
      @response.submitted_at = Time.current

      if @response.save
        respond_to do |format|
          format.json { render json: { status: "success" } }
          format.html { redirect_to participant_assignment_path(@assignment), notice: "Response saved successfully." }
        end
      else
        respond_to do |format|
          format.json { render json: { status: "error", message: @response.errors.full_messages.join(", ") } }
          format.html { redirect_to participant_assignment_path(@assignment), alert: "Failed to save response." }
        end
      end
    end

    private

    def set_assignment
      @assignment = Assignment.current
        .where(id: params[:id])
        .where('EXISTS (SELECT 1 FROM assignment_participants WHERE assignment_id = assignments.id AND participant_id = ?)
               OR EXISTS (SELECT 1 FROM assignment_sections WHERE assignment_id = assignments.id AND section_id = ?)',
               current_participant.id, current_participant.section_id)
        .first!
    end
  end
end
