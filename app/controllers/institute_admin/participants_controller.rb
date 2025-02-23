require "csv"

module InstituteAdmin
  class ParticipantsController < InstituteAdmin::BaseController
    before_action :set_participant, only: [ :show, :edit, :update, :destroy ]
    before_action :set_sections, only: [ :new, :create, :edit, :update ]

    def index
      @participants = current_institute.participants.includes(:user, :section)

      respond_to do |format|
        format.html
        format.pdf do
          pdf = ParticipantReportPdf.new(@participants, current_institute)
          send_data pdf.render,
            filename: "participants_report_#{Date.current}.pdf",
            type: "application/pdf",
            disposition: "inline"
        end
        format.csv do
          send_data generate_csv(@participants),
            filename: "participants_report_#{Date.current}.csv"
        end
      end
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

      if @user.update(update_params)
        redirect_to institute_admin_participants_path,
          notice: "Participant was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @user.destroy
        redirect_to institute_admin_participants_path,
          notice: "Participant was successfully deleted."
      else
        redirect_to institute_admin_participants_path,
          alert: "Failed to delete participant."
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
        participant_attributes: [
          :id,
          :date_of_birth,
          :phone_number,
          :section_id,
          :status
        ]
      )
    end

    def generate_csv(participants)
      CSV.generate(headers: true) do |csv|
        csv << [
          "ID", "Name", "Email", "Section", "Training Programs",
          "Completed Programs", "Active Programs", "Enrollment Date",
          "Status", "Last Active"
        ]

        participants.each do |participant|
          csv << [
            participant.id,
            participant.user.full_name,
            participant.user.email,
            participant.section&.name || "Not Assigned",
            participant.all_training_programs.count,
            participant.completed_programs.count,
            participant.ongoing_programs.count,
            participant.enrollment_date&.strftime("%B %d, %Y"),
            participant.status.titleize,
            participant.user.last_sign_in_at&.strftime("%B %d, %Y %I:%M %p") || "Never"
          ]
        end
      end
    end
  end
end
