require "csv"

module InstituteAdmin
  class ParticipantsController < InstituteAdmin::BaseController
    before_action :set_participant, only: [ :show, :edit, :update, :destroy ]
    before_action :set_sections, only: [ :new, :create, :edit, :update ]

    def index
      @participants = current_institute.participants.includes(:user, :section)
    end

    def show
      @user = @participant.user
      @guardian = @participant.guardian
    end

    def new
      @user = User.new
      @user.build_participant
    end

    def create
      @user = User.new(user_params)
      @user.role = :participant
      @user.institute = current_institute
      
      # Set the section_id on the user model from the participant attributes
      if @user.participant && @user.participant.section_id.present?
        @user.section_id = @user.participant.section_id
      end
      
      @user.participant.institute = current_institute if @user.participant

      if @user.save
        redirect_to institute_admin_participants_path,
          notice: "Participant was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @user = @participant.user
    end

    def update
      @user = @participant.user

      # Only include password params if they're present
      update_params = user_params
      if update_params[:password].blank? && update_params[:password_confirmation].blank?
        update_params = update_params.except(:password, :password_confirmation)
      end
      
      # Set the section_id on the user model from the participant attributes
      if update_params[:participant_attributes] && update_params[:participant_attributes][:section_id].present?
        @user.section_id = update_params[:participant_attributes][:section_id]
      end

      if @user.update(update_params)
        redirect_to institute_admin_participants_path,
          notice: "Participant was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      begin
        if @user.destroy
          redirect_to institute_admin_participants_path,
            notice: "Participant was successfully deleted."
        else
          redirect_to institute_admin_participants_path,
            alert: "Failed to delete participant: #{@user.errors.full_messages.to_sentence}"
        end
      rescue ActiveRecord::InvalidForeignKey => e
        redirect_to institute_admin_participants_path,
          alert: "Cannot delete participant because it is referenced by other records. Please remove those associations first."
      rescue StandardError => e
        redirect_to institute_admin_participants_path,
          alert: "An error occurred: #{e.message}"
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

    def user_params
      params.require(:user).permit(
        :first_name,
        :last_name,
        :email,
        :password,
        :password_confirmation,
        :section_id,
        participant_attributes: [
          :id,
          :date_of_birth,
          :phone_number,
          :section_id,
          :status,
          :institute_id
        ]
      )
    end
  end
end
