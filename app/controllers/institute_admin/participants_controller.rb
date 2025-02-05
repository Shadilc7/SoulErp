module InstituteAdmin
  class ParticipantsController < InstituteAdmin::BaseController
    before_action :set_participant, only: [ :show, :edit, :update ]
    before_action :set_sections, only: [ :new, :create, :edit, :update ]

    def index
      @participants = current_institute.participants.includes(:participant_profile, :section)
    end

    def show
      @participant_profile = @participant.participant_profile
      @guardian = @participant.guardian_profile&.user
    end

    def new
      @participant = User.new
      @participant.build_participant_profile(institute_id: current_institute.id)
    end

    def create
      @participant = User.new(participant_params)
      @participant.institute = current_institute
      @participant.role = :participant
      @participant.participant_profile.institute = current_institute if @participant.participant_profile

      if @participant.save
        redirect_to institute_admin_participant_path(@participant),
          notice: "Participant was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @participant.update(participant_params)
        redirect_to institute_admin_participant_path(@participant),
          notice: "Participant was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_participant
      @participant = current_institute.participants.find(params[:id])
    end

    def set_sections
      @sections = current_institute.sections.active
    end

    def participant_params
      params.require(:user).permit(
        :username, :email, :password, :password_confirmation, :section_id,
        participant_profile_attributes: [
          :id, :date_of_birth, :education_level, :enrollment_date,
          :status, :notes, :institute_id
        ]
      )
    end
  end
end
