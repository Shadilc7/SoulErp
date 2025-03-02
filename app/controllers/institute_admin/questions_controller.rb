module InstituteAdmin
  class QuestionsController < InstituteAdmin::BaseController
    before_action :set_question, only: [ :show, :edit, :update, :destroy ]

    def index
      @questions = current_institute.questions.includes(:options).order(created_at: :desc)
    end

    def show
    end

    def new
      @question = current_institute.questions.build
    end

    def create
      begin
        # Get the parameters first
        question_parameters = sanitize_question_params(question_params)
        
        @question = current_institute.questions.build(question_parameters)

        # Final safety check before saving
        ensure_options_have_text(@question) if @question.requires_options?

        if @question.save
          redirect_to institute_admin_question_path(@question), notice: "Question was successfully created."
        else
          render :new, status: :unprocessable_entity
        end
      rescue => e
        # Log the error
        Rails.logger.error("Error creating question: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
        
        # Create a new question object for the form
        @question = current_institute.questions.build(question_params)
        
        # Add error message
        flash.now[:error] = "An error occurred while creating the question. Please try again."
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      begin
        # Get the parameters first
        question_parameters = sanitize_question_params(question_params)
        
        # Final safety check before updating
        @question.assign_attributes(question_parameters)
        ensure_options_have_text(@question) if @question.requires_options?
        
        if @question.save
          redirect_to institute_admin_question_path(@question), notice: "Question was successfully updated."
        else
          render :edit, status: :unprocessable_entity
        end
      rescue => e
        # Log the error
        Rails.logger.error("Error updating question: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
        
        # Add error message
        flash.now[:error] = "An error occurred while updating the question. Please try again."
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @question = current_institute.questions.find(params[:id])

      if @question.destroy
        flash[:success] = "Question was successfully deleted."
        redirect_to institute_admin_questions_path
      else
        flash[:error] = @question.errors.full_messages.to_sentence
        redirect_to institute_admin_questions_path
      end
    end

    private

    def set_question
      @question = current_institute.questions.includes(:options).find(params[:id])
    end

    def question_params
      params.require(:question).permit(
        :title,
        :description,
        :question_type,
        :required,
        :max_rating,
        options_attributes: [ :id, :text, :correct, :_destroy ]
      )
    end
    
    # Sanitize parameters to ensure no null values for options text
    def sanitize_question_params(params)
      if params[:options_attributes].present?
        params[:options_attributes].each do |key, option_attrs|
          unless option_attrs[:_destroy] == "1"
            option_attrs[:text] = "Option #{Time.now.to_i}" if option_attrs[:text].blank?
          end
        end
      end
      params
    end
    
    # Additional safety check to ensure all options have text
    def ensure_options_have_text(question)
      question.options.each do |option|
        next if option.marked_for_destruction?
        option.text = "Option #{Time.now.to_i}" if option.text.blank?
      end
    end
  end
end
