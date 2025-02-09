module InstituteAdmin
  class DashboardController < InstituteAdmin::BaseController
    def index
      @sections_count = current_institute.sections.count
      @participants_count = current_institute.participants.joins(:user).count
      @trainers_count = current_institute.trainers.joins(:user).count
    end
  end
end
