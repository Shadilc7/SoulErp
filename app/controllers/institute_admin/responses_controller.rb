module InstituteAdmin
  class ResponsesController < InstituteAdmin::BaseController
    before_action :set_assignment, only: [ :index, :show ], if: -> { params[:assignment_id].present? }

    def index
      base_query = if @assignment
        @assignment.assignment_responses
          .includes(participant: [ :section, :user ])
      else
        AssignmentResponse.joins(:participant)
          .where(participants: { institute_id: current_institute.id })
          .includes(:assignment, participant: [ :section, :user ])
      end

      @responses = base_query
        .order(created_at: :desc)
        .page(params[:page])
        .per(10)
    end

    def show
      @response = if @assignment
        @assignment.assignment_responses
          .includes(participant: [ :section, :user ])
          .find(params[:id])
      else
        AssignmentResponse.joins(:participant)
          .where(participants: { institute_id: current_institute.id })
          .includes(:assignment, participant: [ :section, :user ])
          .find(params[:id])
      end
    end

    private

    def set_assignment
      @assignment = current_institute.assignments.find(params[:assignment_id])
    end
  end
end
