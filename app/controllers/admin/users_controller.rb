module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, only: [ :edit, :update ]

    def index
      @users = User.institute_admin
    end

    def new
      @user = User.new
      @institutes = Institute.active
    end

    def create
      @user = User.new(user_params)
      @user.role = :institute_admin

      if @user.save
        redirect_to admin_users_path, notice: "Institute Admin was successfully created."
      else
        @institutes = Institute.active
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @institutes = Institute.active
    end

    def update
      if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end

      if @user.update(user_params)
        redirect_to admin_users_path, notice: "Institute Admin was successfully updated."
      else
        @institutes = Institute.active
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_user
      @user = User.institute_admin.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :username, :password, :password_confirmation, :institute_id, :active)
    end
  end
end
