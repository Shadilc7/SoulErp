module InstituteAdmin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_institute_admin
    layout "institute_admin"

    private

    def require_institute_admin
      unless current_user&.institute_admin?
        redirect_to root_path, alert: "You must be an institute admin to access this area."
      end
    end

    def current_institute
      @current_institute ||= current_user&.institute
    end
    helper_method :current_institute
  end
end
