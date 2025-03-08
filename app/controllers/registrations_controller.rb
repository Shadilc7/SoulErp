class RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]
  before_action :set_sections_and_institutes, only: [ :new, :create ]

  def new
    build_resource({})
    resource.build_participant
    @institutes = Institute.active.where(
      id: RegistrationSetting.instance.enabled_institutes
    )
    respond_with resource
  end

  def create
    build_resource(sign_up_params)
    resource.role = :participant

    # Set the institute_id from participant's institute_id
    if params[:user][:participant_attributes][:institute_id].present?
      resource.institute_id = params[:user][:participant_attributes][:institute_id]
    end

    if resource.save
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        # Instead of signing in, redirect to login page
        redirect_to new_user_session_path, notice: "Registration successful! Please login to continue."
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        redirect_to new_user_session_path
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      # Re-fetch institutes and sections for the form
      set_sections_and_institutes
      respond_with resource
    end
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :first_name,
      :last_name,
      :email,
      participant_attributes: [
        :phone_number,
        :date_of_birth,
        :institute_id,
        :section_id,
        :participant_type,
        :address,
        :pin_code,
        :district,
        :state
      ]
    ])
  end

  def build_resource(hash = {})
    super
    resource.role = :participant
    resource.build_participant if resource.participant.nil?
    resource.participant.enrollment_date = Date.current if resource.participant
  end

  private

  def set_sections_and_institutes
    @institutes = Institute.active
    @sections = Section.active
  end
end
