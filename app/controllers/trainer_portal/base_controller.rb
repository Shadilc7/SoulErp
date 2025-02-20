module TrainerPortal
  class BaseController < ApplicationController
    layout 'trainer'
    before_action :authenticate_user!
    before_action :ensure_trainer!

    private

    def ensure_trainer!
      unless current_user.trainer?
        flash[:alert] = "You are not authorized to access this area."
        redirect_to root_path
      end
    end

    def current_trainer
      @current_trainer ||= current_user.trainer
    end

    def current_institute
      @current_institute ||= current_trainer.institute
    end

    helper_method :current_trainer, :current_institute
  end
end
