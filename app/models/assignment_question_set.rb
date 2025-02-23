class AssignmentQuestionSet < ApplicationRecord
  belongs_to :assignment
  belongs_to :question_set
end
