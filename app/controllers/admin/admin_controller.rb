module Admin
  class AdminController < Admin::BaseController

    def dashboard
      @institutes_count = Institute.count
      @institute_admins_count = User.institute_admin.count
      @active_programs_count = TrainingProgram.where(status: :active).count
      @recent_institutes = Institute.order(created_at: :desc).limit(5)
    end
  end
end
