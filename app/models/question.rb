class Question < ApplicationRecord
  belongs_to :institute
  has_many :question_set_items, dependent: :destroy
  has_many :question_sets, through: :question_set_items
  has_many :options, dependent: :destroy
  accepts_nested_attributes_for :options, allow_destroy: true, reject_if: :all_blank

  validates :title, presence: true
  validates :question_type, presence: true
  validates :marks, presence: true, numericality: { greater_than: 0 }
  validates :options, presence: true, if: :requires_options?

  enum :question_type, {
    short_answer: 0,    # Text input for short answers
    paragraph: 1,       # Text area for longer answers
    multiple_choice: 2, # Radio buttons, single answer
    checkboxes: 3,      # Checkboxes, multiple answers
    dropdown: 4,        # Dropdown select, single answer
    date: 5,           # Date picker
    time: 6            # Time picker
  }, default: :short_answer

  enum :difficulty_level, {
    easy: 0,
    medium: 1,
    hard: 2
  }, default: :medium

  # Add scope for active questions
  scope :active, -> { where(active: true) }

  def requires_options?
    %w[multiple_choice checkboxes dropdown].include?(question_type)
  end

  private

  def validate_options_and_answers
    if requires_options? && options.size < 2
      errors.add(:options, "must have at least 2 options")
    end
  end
end
