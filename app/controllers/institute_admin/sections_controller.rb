module InstituteAdmin
  class SectionsController < InstituteAdmin::BaseController
    before_action :set_section, only: [ :show, :edit, :update, :destroy ]

    def index
      @sections = current_institute.sections.includes(:participants)
    end

    def show
      @participants = @section.participants.includes(:participant_profile)
    end

    def new
      @section = current_institute.sections.build
    end

    def create
      @section = current_institute.sections.build(section_params)

      if @section.save
        redirect_to institute_admin_section_path(@section), notice: "Section was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @section.update(section_params)
        redirect_to institute_admin_section_path(@section), notice: "Section was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @section = current_institute.sections.find(params[:id])

      if @section.destroy
        redirect_to institute_admin_sections_path, notice: "Section was successfully deleted."
      else
        redirect_to institute_admin_sections_path, alert: "Failed to delete section."
      end
    end

    private

    def set_section
      @section = current_institute.sections.find(params[:id])
    end

    def section_params
      params.require(:section).permit(:name, :code, :capacity, :description, :active)
    end
  end
end
