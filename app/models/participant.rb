class Participant < ApplicationRecord
  belongs_to :user
  belongs_to :institute
  has_one :guardian, dependent: :destroy

  # Get section through user
  has_one :section, through: :user

  # Update training program associations with dependent: :nullify
  has_many :training_programs, dependent: :nullify
  has_many :section_training_programs, through: :section, source: :training_programs

  # Add these associations with dependent: :destroy
  has_many :assignment_participants, dependent: :destroy
  has_many :assignments, through: :assignment_participants

  # Simplified phone number validation
  validates :phone_number, presence: true
  validates :date_of_birth, presence: true
  validates :institute_id, presence: true
  validates :user, presence: true

  # Add callbacks for both create and update
  after_create :sync_user_associations
  after_save :sync_user_associations

  enum :status, {
    active: 0,
    inactive: 1,
    on_leave: 2,
    graduated: 3,
    dropped: 4
  }, default: :active

  accepts_nested_attributes_for :guardian

  scope :active, -> { where(status: :active) }
  scope :with_user, -> { includes(:user) }

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

  private

  def sync_user_associations
    return unless user.present?
    user.update_columns(
      institute_id: institute_id,
      section_id: section_id
    )
  end
end
