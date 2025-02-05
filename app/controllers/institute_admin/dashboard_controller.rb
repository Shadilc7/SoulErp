module InstituteAdmin
  class DashboardController < InstituteAdmin::BaseController
    def index
      @sections_count = current_institute.sections.count
      @participants_count = current_institute.users.participant.count
      @trainers_count = current_institute.users.trainer.count
    end
  end
end
