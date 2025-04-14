require "csv"

module InstituteAdmin
  class SectionsController < InstituteAdmin::BaseController
    skip_before_action :authenticate_user!, only: [ :fetch ]
    skip_before_action :verify_authenticity_token, only: [ :fetch ]
    skip_before_action :require_institute_admin, only: [ :fetch ]

    before_action :set_section, only: [ :show, :edit, :update, :destroy ]

    def index
      @sections = current_institute.sections
        .select("sections.*, (
          SELECT COUNT(*)
          FROM users
          WHERE users.section_id = sections.id
          AND users.role = #{User.roles[:participant]}
        ) as participants_count")
        .includes(:participants)
    end

    def show
      @participants = @section.participants
    end

    def new
      @section = current_institute.sections.build
    end

    def create
      @section = current_institute.sections.build(section_params)

      if @section.save
        redirect_to institute_admin_section_path(@section), notice: "Section was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @section.update(section_params)
        redirect_to institute_admin_section_path(@section), notice: "Section was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @section = current_institute.sections.find(params[:id])
      
      if @section.destroy
        redirect_to institute_admin_sections_path, notice: "Section was successfully deleted."
      else
        redirect_to institute_admin_sections_path, 
          alert: @section.errors.full_messages.first || "Unable to delete section."
      end
    end

    def reassign_users
      @section = current_institute.sections.find(params[:id])
      @users = @section.users
      @sections = current_institute.sections.where.not(id: @section.id).active
      
      if request.post?
        action_type = params[:action_type]
        
        if action_type == "reassign" && params[:target_section_id].present?
          # Update all users to the new section
          @users.update_all(section_id: params[:target_section_id])
          
          # Now try to delete the section
          if @section.destroy
            redirect_to institute_admin_sections_path, notice: "Users reassigned and section was successfully deleted."
          else
            redirect_to institute_admin_sections_path, alert: "Users reassigned but section could not be deleted."
          end
        elsif action_type == "remove"
          # Remove section association from all users
          @users.update_all(section_id: nil)
          
          # Now try to delete the section
          if @section.destroy
            redirect_to institute_admin_sections_path, notice: "Users removed from section and section was successfully deleted."
          else
            redirect_to institute_admin_sections_path, alert: "Users removed but section could not be deleted."
          end
        else
          flash.now[:alert] = "Please select a valid action and target section if reassigning."
          render :reassign_users
        end
      end
    end

    def fetch
      @sections = if params[:institute_id].present?
        institute = Institute.find(params[:institute_id])
        institute.sections.active.order(:name)
      else
        Section.none
      end

      render json: @sections.map { |s| { id: s.id, name: s.name } }
    rescue ActiveRecord::RecordNotFound
      render json: [], status: :not_found
    end

    def participants
      begin
        @section = current_institute.sections.find(params[:id])
        
        # Filter to include only active student participants using association
        @participants = @section.participants
                                .includes(:user)
                                .where(status: :active)
                                .where(participant_type: 'student')
        
        # If no participants found via association, try direct SQL query
        if @participants.empty?
          # Direct query to find participants through user's section_id
          @participants = Participant.joins(:user)
                                    .where(users: { section_id: @section.id })
                                    .where(participants: { status: :active })
                                    .where(participants: { participant_type: 'student' })
        end

        # Map participant data for the response
        result = @participants.map { |p|
          {
            id: p.id,
            full_name: p.user&.full_name || "Participant #{p.id}",
            user_id: p.user&.id,
            email: p.user&.email
          }
        }
        
        render json: result
      rescue => e
        Rails.logger.error "Error loading participants: #{e.message}"
        render json: { error: e.message }, status: :internal_server_error
      end
    end

    private

    def set_section
      @section = current_institute.sections.find(params[:id])
    end

    def section_params
      params.require(:section).permit(
        :name, :code, :capacity, :description, :status
      )
    end
  end
end
