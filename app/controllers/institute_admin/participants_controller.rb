module InstituteAdmin
  class ParticipantsController < InstituteAdmin::BaseController
    before_action :set_participant, only: [ :show, :edit, :update ]
    before_action :set_sections, only: [ :new, :create, :edit, :update ]

    def index
      @participants = current_institute.participants.includes(:user)
    end

    def show
      @guardian = @participant.guardian&.user
    end

    def new
      @user = User.new
      @user.build_participant(institute_id: current_institute.id)
    end

    def create
      @user = User.new(participant_params)
      @user.institute = current_institute
      @user.role = :participant
      @user.participant.institute = current_institute if @user.participant

      if @user.save
        redirect_to institute_admin_participant_path(@user),
          notice: "Participant was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      # @participant and @user are set by set_participant
    end

    def update
      if @user.update(participant_params)
        redirect_to institute_admin_participant_path(@user),
          notice: "Participant was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user = current_institute.users.find(params[:id])
      @participant = @user.participant

      if @user.destroy
        redirect_to institute_admin_participants_path, notice: "Participant was successfully deleted."
      else
        redirect_to institute_admin_participants_path, alert: "Failed to delete participant."
      end
    end

    private

    def set_participant
      @user = current_institute.users.find(params[:id])
      @participant = @user.participant
      raise ActiveRecord::RecordNotFound unless @participant
    end

    def set_sections
      @sections = current_institute.sections.active
    end

    def participant_params
      params.require(:user).permit(
        :username, :email, :password, :password_confirmation, :section_id,
        participant_attributes: [
          :id, :date_of_birth, :education_level, :enrollment_date,
          :status, :notes, :institute_id
        ]
      )
    end
  end
end
