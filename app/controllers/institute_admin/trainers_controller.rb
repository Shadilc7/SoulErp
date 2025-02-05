module InstituteAdmin
  class TrainersController < InstituteAdmin::BaseController
    before_action :set_trainer, only: [ :show, :edit, :update ]

    def index
      @trainers = current_institute.trainers.includes(:trainer_profile)
    end

    def show
      @trainer_profile = @trainer.trainer_profile
    end

    def new
      @trainer = User.new
      @trainer.build_trainer_profile(institute_id: current_institute.id)
    end

    def create
      @trainer = User.new(trainer_params)
      @trainer.institute = current_institute
      @trainer.role = :trainer
      @trainer.trainer_profile.institute = current_institute if @trainer.trainer_profile

      if @trainer.save
        redirect_to institute_admin_trainer_path(@trainer),
          notice: "Trainer was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @trainer.update(trainer_params)
        redirect_to institute_admin_trainer_path(@trainer),
          notice: "Trainer was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_trainer
      @trainer = current_institute.trainers.find(params[:id])
    end

    def trainer_params
      params.require(:user).permit(
        :username, :email, :password, :password_confirmation,
        trainer_profile_attributes: [
          :id, :specialization, :qualification, :experience_years,
          :status, :institute_id
        ]
      )
    end
  end
end
