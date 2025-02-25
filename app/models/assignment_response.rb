class AssignmentResponse < ApplicationRecord
  belongs_to :participant
  belongs_to :assignment
  belongs_to :question
  has_one :section, through: :participant

  validates :participant_id, presence: true
  validates :assignment_id, presence: true
  validates :question_id, presence: true
  validates :response_date, presence: true

  scope :ordered, -> { order(created_at: :desc) }

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
