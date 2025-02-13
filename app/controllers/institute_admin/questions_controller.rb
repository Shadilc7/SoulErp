module InstituteAdmin
  class QuestionsController < InstituteAdmin::BaseController
    before_action :set_question, only: [ :show, :edit, :update, :destroy ]

    def index
      @questions = current_institute.questions.order(created_at: :desc)
    end

    def show
    end

    def new
      @question = current_institute.questions.build
    end

    def create
      @question = current_institute.questions.build(question_params)

      if @question.save
        redirect_to institute_admin_question_path(@question), notice: "Question was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @question.update(question_params)
        redirect_to institute_admin_question_path(@question), notice: "Question was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @question.destroy
      redirect_to institute_admin_questions_path, notice: "Question was successfully deleted."
    end

    private

    def set_question
      @question = current_institute.questions.find(params[:id])
    end

    def question_params
      params.require(:question).permit(
        :title, :description, :question_type, :marks,
        :difficulty_level, :active, :correct_option,
        :correct_answer, options: []
      )
    end
  end
end
