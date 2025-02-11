module InstituteAdmin
  class TrainersController < InstituteAdmin::BaseController
    before_action :set_trainer, only: [ :show, :edit, :update ]

    def index
      @trainers = current_institute.trainers.includes(:user)
    end

    def show
      # @trainer and @user are set by set_trainer
    end

    def new
      @user = User.new
      @user.build_trainer(institute_id: current_institute.id)
    end

    def create
      @user = User.new(trainer_params)
      @user.institute = current_institute
      @user.role = :trainer
      @user.trainer.institute = current_institute if @user.trainer

      if @user.save
        redirect_to institute_admin_trainer_path(@user),
          notice: "Trainer was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      # @trainer and @user are set by set_trainer
    end

    def update
      if @user.update(trainer_params)
        redirect_to institute_admin_trainer_path(@user),
          notice: "Trainer was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user = current_institute.users.find(params[:id])
      @trainer = @user.trainer

      if @user.destroy
        redirect_to institute_admin_trainers_path, notice: "Trainer was successfully deleted."
      else
        redirect_to institute_admin_trainers_path, alert: "Failed to delete trainer."
      end
    end

    private

    def set_trainer
      @user = current_institute.users.find(params[:id])
      @trainer = @user.trainer
      raise ActiveRecord::RecordNotFound unless @trainer
    end

    def trainer_params
      params.require(:user).permit(
        :username, :email, :password, :password_confirmation,
        trainer_attributes: [
          :id, :specialization, :qualification, :experience_years,
          :status, :institute_id
        ]
      )
    end
  end
end
