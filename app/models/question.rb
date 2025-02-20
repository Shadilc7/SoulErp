class Question < ApplicationRecord
  belongs_to :institute
  has_many :question_set_items, dependent: :destroy
  has_many :question_sets, through: :question_set_items

  validates :title, presence: true
  validates :question_type, presence: true
  validates :marks, presence: true, numericality: { greater_than: 0 }
  validate :validate_options_and_answers

  enum :question_type, {
    multiple_choice: 0,
    single_choice: 1,
    true_false: 2,
    short_answer: 3,
    long_answer: 4,
    fill_in_blank: 5
  }

  enum :difficulty_level, {
    easy: 0,
    medium: 1,
    hard: 2
  }

  # Add scope for active questions
  scope :active, -> { where(active: true) }

  private

  def validate_options_and_answers
    case question_type
    when "multiple_choice", "single_choice"
      if options.blank? || !options.is_a?(Array) || options.size < 2
        errors.add(:options, "must have at least 2 options")
      end
      if correct_option.nil? || correct_option.negative? || correct_option >= options.size
        errors.add(:correct_option, "must be a valid option index")
      end
    when "true_false"
      if correct_answer.nil? || ![ "true", "false" ].include?(correct_answer.to_s.downcase)
        errors.add(:correct_answer, "must be true or false")
      end
    when "short_answer", "long_answer", "fill_in_blank"
      if correct_answer.blank?
        errors.add(:correct_answer, "can't be blank")
      end
    end
  end
end
