module ParticipantPortal
  class ProfilesController < ParticipantPortal::BaseController
    def show
      @participant = current_participant
    end
  end
end
