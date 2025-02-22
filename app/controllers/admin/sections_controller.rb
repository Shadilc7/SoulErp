class Admin::SectionsController < ApplicationController
  def index
    @sections = Section.where(institute_id: params[:institute_id])
    render json: @sections
  end
end
