class Participant < ApplicationRecord
  belongs_to :user, dependent: :destroy
  belongs_to :section, optional: true
  belongs_to :institute
  has_one :guardian, dependent: :destroy

  # Add training program associations
  has_many :training_programs
  has_many :section_training_programs, through: :section, source: :training_programs

  validates :date_of_birth, presence: true
  validates :education_level, presence: true
  validates :enrollment_date, presence: true
  validates :institute_id, presence: true

  enum :status, {
    active: 0,
    inactive: 1,
    on_leave: 2,
    graduated: 3,
    dropped: 4
  }, default: :active

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :guardian

  scope :active, -> { where(status: :active) }

  # Helper method to get all training programs (both individual and section)
  def all_training_programs
    TrainingProgram.where(
      "participant_id = ? OR section_id = ?",
      id,
      section_id
    )
  end

  # Methods to get training programs by status
  def completed_programs
    all_training_programs.completed
  end

  def ongoing_programs
    all_training_programs.ongoing
  end
end
