class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index ]

  def index
    return unless user_signed_in?

    path = case current_user.role
    when "master_admin"
      admin_root_path
    when "institute_admin"
      institute_admin_root_path
    when "trainer"
      trainer_portal_root_path
    when "participant"
      if current_user.participant.present?
        participant_portal_root_path
      else
        sign_out current_user
        root_path
      end
    end

    redirect_to path if path.present?
  end
end
