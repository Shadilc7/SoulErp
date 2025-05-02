module Admin
  class AdminController < Admin::BaseController
    before_action :clear_impersonation_session

    def dashboard
      @institutes_count = Institute.count
      @institute_admins_count = User.institute_admin.count
      @active_programs_count = TrainingProgram.where(status: :active).count
      @recent_institutes = Institute.order(created_at: :desc).limit(5)
    end

    private

    def clear_impersonation_session
      session.delete(:admin_institute_id)
      session.delete(:admin_return_to)
    end
  end
end
