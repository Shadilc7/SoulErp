module ParticipantPortal
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_participant_access
    layout "participant"

    private

    def require_participant_access
      unless current_user&.participant? && current_user&.participant.present?
        redirect_to root_path,
          alert: "Access denied. Please contact your administrator."
      end
    end

    def current_participant
      @current_participant ||= current_user&.participant
    end
    helper_method :current_participant

    def current_institute
      @current_institute ||= current_user&.institute
    end
    helper_method :current_institute
  end
end
