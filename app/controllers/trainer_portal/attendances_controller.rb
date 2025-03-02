module TrainerPortal
  class AttendancesController < TrainerPortal::BaseController
    before_action :set_training_program
    before_action :set_date, only: [:new, :create]

    def index
      @attendances = @training_program.attendances
        .includes(:participant)
        .order(date: :desc)
        .group_by(&:date)
    end

    def new
      if @training_program.attendance_marked?(@date)
        redirect_to trainer_portal_training_program_attendances_path(@training_program),
          alert: "Attendance already marked for #{@date.strftime('%B %d, %Y')}"
        return
      end

      @participants = @training_program.all_participants
    end

    def create
      ActiveRecord::Base.transaction do
        attendance_params[:attendances].each do |participant_id, status|
          @training_program.attendances.create!(
            participant_id: participant_id,
            date: @date,
            status: status,
            marked_by: current_user
          )
        end

        redirect_to trainer_portal_training_program_attendances_path(@training_program),
          notice: "Attendance marked successfully for #{@date.strftime('%B %d, %Y')}"
      end
    rescue ActiveRecord::RecordInvalid => e
      redirect_to new_trainer_portal_training_program_attendance_path(@training_program, date: @date),
        alert: "Error marking attendance: #{e.message}"
    end

    private

    def set_training_program
      @training_program = current_trainer.training_programs.find(params[:training_program_id])
    end

    def set_date
      begin
        @date = params[:date].present? ? Date.parse(params[:date]) : Date.current
      rescue ArgumentError
        @date = Date.current
      end
    end

    def attendance_params
      params.require(:attendance).permit(attendances: {})
    end
  end
end 