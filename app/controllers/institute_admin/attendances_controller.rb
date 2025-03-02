module InstituteAdmin
  class AttendancesController < InstituteAdmin::BaseController
    before_action :set_training_program, only: [:mark, :record, :edit, :update, :history]
    before_action :set_date, only: [:mark, :record, :edit, :update]

    def index
      @training_programs = current_institute.training_programs
        .includes(:trainer, :section, participant: :user)
        .where(status: :ongoing)
        .order(created_at: :desc)
    end

    def mark
      if @training_program.attendance_marked?(@date)
        redirect_to institute_admin_attendances_path,
          alert: "Attendance already marked for #{@date.strftime('%B %d, %Y')}"
        return
      end

      @participants = @training_program.all_participants
    end

    def record
      ActiveRecord::Base.transaction do
        attendance_params[:attendances].each do |participant_id, status|
          @training_program.attendances.create!(
            participant_id: participant_id,
            date: @date,
            status: status,
            marked_by: current_user
          )
        end

        redirect_to institute_admin_attendances_path,
          notice: "Attendance marked successfully for #{@date.strftime('%B %d, %Y')}"
      end
    rescue ActiveRecord::RecordInvalid => e
      redirect_to mark_institute_admin_attendance_path(@training_program, date: @date),
        alert: "Error marking attendance: #{e.message}"
    end
    
    def edit
      unless @training_program.attendance_marked?(@date)
        redirect_to institute_admin_attendances_path,
          alert: "No attendance record found for #{@date.strftime('%B %d, %Y')}"
        return
      end
      
      @participants = @training_program.all_participants
      @attendances = @training_program.attendances.by_date(@date).index_by(&:participant_id)
    end
    
    def update
      ActiveRecord::Base.transaction do
        attendance_params[:attendances].each do |participant_id, status|
          attendance = @training_program.attendances.find_or_initialize_by(
            participant_id: participant_id,
            date: @date
          )
          
          if attendance.new_record?
            attendance.marked_by = current_user
          end
          
          attendance.status = status
          attendance.save!
        end
        
        redirect_to institute_admin_attendances_path,
          notice: "Attendance updated successfully for #{@date.strftime('%B %d, %Y')}"
      end
    rescue ActiveRecord::RecordInvalid => e
      redirect_to edit_institute_admin_attendance_path(@training_program, date: @date),
        alert: "Error updating attendance: #{e.message}"
    end
    
    def history
      @attendance_dates = @training_program.attendances
        .select(:date)
        .distinct
        .order(date: :desc)
        .pluck(:date)
        
      @participants = @training_program.all_participants.includes(:user)
      
      # Create a hash of attendance records by date and participant
      @attendance_records = {}
      
      @attendance_dates.each do |date|
        @attendance_records[date] = @training_program.attendances
          .where(date: date)
          .includes(:participant)
          .index_by(&:participant_id)
      end
    end

    private

    def set_training_program
      @training_program = current_institute.training_programs.find(params[:id])
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