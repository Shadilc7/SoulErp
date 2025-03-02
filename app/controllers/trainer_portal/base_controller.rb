module TrainerPortal
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_trainer
    layout "trainer"

    private

    def require_trainer
      unless current_user&.trainer?
        redirect_to root_path, alert: "You must be a trainer to access this area."
      end
    end

    def current_trainer
      @current_trainer ||= current_user&.trainer
    end
    helper_method :current_trainer

    def current_institute
      @current_institute ||= current_trainer&.institute
    end
    helper_method :current_institute
  end
end
