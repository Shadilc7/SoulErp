module InstituteAdmin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :verify_institute_admin
    layout "institute_admin"

    private

    def verify_institute_admin
      unless current_user&.institute_admin?
        flash[:alert] = "You are not authorized to access this area"
        redirect_to root_path
      end
    end

    def current_institute
      @current_institute ||= current_user.institute
    end
  end
end
