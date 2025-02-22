module Admin
  class InstitutesController < Admin::BaseController
    before_action :set_institute, only: [ :show, :edit, :update ]

    def index
      @institutes = Institute.all
    end

    def show
      @institute_admins = @institute.users.institute_admin
      @available_admins = User.institute_admin.where(institute_id: nil)
    end

    def new
      @institute = Institute.new
    end

    def create
      @institute = Institute.new(institute_params)

      if @institute.save
        redirect_to admin_institutes_path, notice: "Institute was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @institute.update(institute_params)
        redirect_to admin_institute_path(@institute), notice: "Institute was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def assign_admin
      @institute = Institute.find(params[:id])
      @user = User.find(params[:user_id])

      if @user.update(institute_id: @institute.id)
        redirect_to admin_institute_path(@institute), notice: "Admin successfully assigned to institute."
      else
        redirect_to admin_institute_path(@institute), alert: "Failed to assign admin."
      end
    end

    def unassign_admin
      @institute = Institute.find(params[:id])
      @user = User.find(params[:user_id])

      if @user.update(institute_id: nil)
        redirect_to admin_institute_path(@institute), notice: "Admin successfully unassigned from institute."
      else
        redirect_to admin_institute_path(@institute), alert: "Failed to unassign admin."
      end
    end

    def sections
      @sections = Section.where(institute_id: params[:institute_id])
      render json: @sections
    end

    private

    def set_institute
      @institute = Institute.find(params[:id])
    end

    def institute_params
      params.require(:institute).permit(:name, :code, :description, :address, :contact_number, :email, :active, :institution_type)
    end
  end
end
