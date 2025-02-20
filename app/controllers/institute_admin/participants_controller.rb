require "csv"

module InstituteAdmin
  class ParticipantsController < InstituteAdmin::BaseController
    before_action :set_participant, only: [ :show, :edit, :update ]
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
      if @user.participant
        @user.participant.institute = current_institute
        @user.participant.enrollment_date ||= Date.current
      end

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
        :id, :username, :email, :password, :password_confirmation,
        :first_name, :last_name, :active, :section_id,
        participant_attributes: [
          :id, :institute_id, :date_of_birth, :education_level,
          :enrollment_date, :status, :notes
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
