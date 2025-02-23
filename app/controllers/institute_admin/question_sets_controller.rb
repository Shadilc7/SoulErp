module InstituteAdmin
  class QuestionSetsController < InstituteAdmin::BaseController
    before_action :set_question_set, only: [ :show, :edit, :update, :destroy ]

    def index
      @question_sets = current_institute.question_sets.order(created_at: :desc)
    end

    def show
    end

    def new
      @question_set = current_institute.question_sets.build
    end

    def create
      @question_set = current_institute.question_sets.build(question_set_params)

      if @question_set.save
        redirect_to institute_admin_question_sets_path, notice: "Question set was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @question_set.update(question_set_params)
        redirect_to institute_admin_question_sets_path, notice: "Question set was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @question_set.destroy
      redirect_to institute_admin_question_sets_path, notice: "Question set was successfully deleted."
    end

    private

    def set_question_set
      @question_set = current_institute.question_sets.find(params[:id])
    end

    def question_set_params
      params.require(:question_set).permit(:title, question_ids: [])
    end
  end
end
