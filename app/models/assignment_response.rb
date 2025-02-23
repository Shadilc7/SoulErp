class AssignmentResponse < ApplicationRecord
  belongs_to :assignment
  belongs_to :participant
  belongs_to :question

  validates :participant, presence: true
  validates :question, presence: true
  validates :assignment, presence: true

  validate :validate_response_format

  private

  def validate_response_format
    case question.question_type
    when "multiple_choice", "checkboxes"
      errors.add(:selected_options, "must be present") if selected_options.blank?
    when "short_answer", "paragraph"
      errors.add(:answer, "must be present") if answer.blank?
    end
  end
end
