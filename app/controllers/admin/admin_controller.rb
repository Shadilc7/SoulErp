module Admin
  class AdminController < Admin::BaseController
    def test
      Rails.logger.debug "In test action"
      Rails.logger.debug "Layout: #{self.class.send(:_layout)}"
    end

    def dashboard
      Rails.logger.debug "In admin dashboard action"
      Rails.logger.debug "Current user: #{current_user.inspect}"

      @institutes_count = Institute.count
      @institute_admins_count = User.institute_admin.count
      @active_programs_count = TrainingProgram.where(status: :active).count
      @recent_institutes = Institute.order(created_at: :desc).limit(5)

      Rails.logger.debug "Dashboard variables set"
    end
  end
end
