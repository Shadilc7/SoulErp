module InstituteAdmin
  class TrainingProgramsController < InstituteAdmin::BaseController
    before_action :set_training_program, only: [ :show, :edit, :update, :destroy ]

    def index
      @training_programs = current_institute.training_programs
        .includes(:trainer, :section, :participant)
        .order(created_at: :desc)

      if params[:program_type].present?
        @training_programs = @training_programs.where(program_type: params[:program_type])
      end

      if params[:status].present?
        @training_programs = @training_programs.where(status: params[:status])
      end

      if params[:search].present?
        @training_programs = @training_programs.where("title ILIKE ?", "%#{params[:search]}%")
      end
    end

    def show
    end

    def new
      @training_program = current_institute.training_programs.build
      @training_program.program_type = params[:program_type] if params[:program_type]
    end

    def create
      @training_program = current_institute.training_programs.build(training_program_params)

      if @training_program.save
        redirect_to institute_admin_training_program_path(@training_program),
          notice: "Training program was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @training_program.update(training_program_params)
        redirect_to institute_admin_training_program_path(@training_program),
          notice: "Training program was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @training_program.destroy
      redirect_to institute_admin_training_programs_path,
        notice: "Training program was successfully deleted."
    end

    private

    def set_training_program
      @training_program = current_institute.training_programs.find(params[:id])
    end

    def training_program_params
      params.require(:training_program).permit(
        :title, :description, :program_type, :start_date, :end_date,
        :status, :trainer_id, :section_id, :participant_id
      )
    end
  end
end
