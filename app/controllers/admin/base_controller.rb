module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :verify_admin
    layout "admin"

    private

    def verify_admin
      Rails.logger.debug "Layout being used: #{self.class.send(:_layout)}"
      unless current_user&.master_admin?
        flash[:alert] = "You are not authorized to access this area"
        redirect_to root_path
      end
    end
  end
end
