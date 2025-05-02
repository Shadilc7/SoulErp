module InstituteAdmin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_institute_admin
    layout "institute_admin"

    private

    def require_institute_admin
      unless current_user&.institute_admin? || (current_user&.master_admin? && session[:admin_institute_id].present?)
        redirect_to root_path, alert: "You must be an institute admin to access this area."
      end
    end

    def current_institute
      if current_user.master_admin? && session[:admin_institute_id].present?
        @current_institute ||= Institute.find_by(id: session[:admin_institute_id])
      else
        @current_institute ||= current_user&.institute
      end
    end
    helper_method :current_institute
  end
end
