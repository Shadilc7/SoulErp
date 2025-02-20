module Participant
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_participant
    layout "participant"

    private

    def require_participant
      unless current_user&.participant?
        redirect_to root_path, alert: "You must be a participant to access this area."
      end
    end

    def current_participant
      @current_participant ||= current_user&.participant
    end
    helper_method :current_participant
  end
end
