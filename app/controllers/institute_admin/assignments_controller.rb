module InstituteAdmin
  class AssignmentsController < InstituteAdmin::BaseController
    before_action :set_assignment, only: [ :show, :edit, :update, :destroy ]

    def index
      @assignments = current_institute.assignments.order(created_at: :desc)
    end

    def show
      @assignment = current_institute.assignments
        .includes(:section, participants: :user)
        .find(params[:id])
    end

    def new
      @assignment = current_institute.assignments.build(assignment_type: "individual")
    end

    def create
      @assignment = current_institute.assignments.build(assignment_params)

      if @assignment.save
        redirect_to institute_admin_assignments_path, notice: "Assignment was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @sections = current_institute.sections.active
      @selected_sections = @assignment.sections
      @selected_participants = @assignment.participants.includes(:user)
    end

    def update
      if @assignment.update(assignment_params)
        redirect_to institute_admin_assignments_path, notice: "Assignment was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @assignment.destroy
      redirect_to institute_admin_assignments_path, notice: "Assignment was successfully deleted."
    end

    private

    def set_assignment
      @assignment = current_institute.assignments
        .includes(:sections, participants: :user)
        .find(params[:id])
    end

    def assignment_params
      params.require(:assignment).permit(
        :title, :description, :start_date, :end_date, :active, :assignment_type,
        :section_id,
        section_ids: [], participant_ids: [],
        question_ids: [], question_set_ids: []
      )
    end
  end
end
