class QuestionSet < ApplicationRecord
  belongs_to :institute
  has_many :question_set_items, dependent: :destroy
  has_many :questions, through: :question_set_items
  has_many :assignment_question_sets, dependent: :restrict_with_error
  has_many :assignments, through: :assignment_question_sets

  validates :title, presence: true
  validates :questions, presence: true

  validate :no_duplicate_questions
  validate :valid_total_marks

  before_save :calculate_total_marks
  before_destroy :check_assignment_associations

  accepts_nested_attributes_for :question_set_items,
    allow_destroy: true,
    reject_if: :all_blank

  private

  def no_duplicate_questions
    question_ids = question_set_items.map(&:question_id).compact
    if question_ids.uniq.length != question_ids.length
      errors.add(:base, "Cannot have duplicate questions in the same set")
    end
  end

  def valid_total_marks
    total = calculate_total_marks
    if total == 0
      errors.add(:base, "Question set must have at least one question")
    elsif total > 100
      errors.add(:base, "Total marks cannot exceed 100")
    end
  end

  def calculate_total_marks
    if question_set_items.present?
      self.total_marks = question_set_items.sum { |item| item.marks_override || 1 }
    else
      self.total_marks = 0
    end
  end

  def check_assignment_associations
    if assignments.exists?
      errors.add(:base, "This question set cannot be deleted because it is being used in #{assignments.count} #{'assignment'.pluralize(assignments.count)}")
      throw :abort
    end
  end
end
