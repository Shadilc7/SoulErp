module InstituteAdmin
  class TrainersController < InstituteAdmin::BaseController
    before_action :set_trainer, only: [ :show, :edit, :update, :destroy ]

    def index
      @trainers = current_institute.trainers
        .includes(:user)
        .order(created_at: :desc)
    end

    def show
      # @trainer and @user are set by set_trainer
    end

    def new
      @trainer = current_institute.trainers.build
      @trainer.build_user
    end

    def create
      @trainer = current_institute.trainers.build(trainer_params)
      @trainer.user.institute = current_institute
      @trainer.user.role = :trainer
      @trainer.institute = current_institute  # Explicitly set the institute

      if @trainer.save
        redirect_to institute_admin_trainer_path(@trainer),
          notice: "Trainer was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      # @trainer and @user are set by set_trainer
    end

    def update
      # Remove password params if they're blank
      if params[:trainer][:user_attributes][:password].blank? && params[:trainer][:user_attributes][:password_confirmation].blank?
        params[:trainer][:user_attributes].delete(:password)
        params[:trainer][:user_attributes].delete(:password_confirmation)
      end

      if @trainer.update(trainer_params)
        redirect_to institute_admin_trainer_path(@trainer),
          notice: "Trainer was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @trainer.destroy
      redirect_to institute_admin_trainers_path,
        notice: "Trainer was successfully deleted."
    end

    private

    def set_trainer
      @trainer = current_institute.trainers
        .includes(:user, training_programs: [ :section, :participant ])
        .find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = "Trainer not found or you don't have access to this trainer."
      redirect_to institute_admin_trainers_path
    end

    def trainer_params
      params.require(:trainer).permit(
        :specialization,
        :qualification,
        :experience_years,
        :phone_number,
        :status,
        :certificates,
        :experience_details,
        :payment_details,
        :other_details,
        user_attributes: [
          :id,
          :first_name,
          :last_name,
          :email,
          :password,
          :password_confirmation
        ]
      )
    end
  end
end
