class Participant < ApplicationRecord
  belongs_to :user
  belongs_to :institute
  has_one :guardian, dependent: :destroy
  has_many :assignment_responses, dependent: :destroy

  # Get section through user
  has_one :section, through: :user

  # Update training program associations with dependent: :nullify
  has_many :individual_training_programs, class_name: 'TrainingProgram', foreign_key: 'participant_id', dependent: :nullify
  has_many :section_training_programs, through: :section, source: :training_programs

  # Add the training_program_participants association with dependent: :destroy
  has_many :training_program_participants, dependent: :destroy
  has_many :training_programs, through: :training_program_participants

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

  delegate :full_name, :email, to: :user

  # Helper method to get all training programs (both individual and section)
  def all_training_programs
    TrainingProgram.where(id: individual_training_programs.pluck(:id) + training_programs.pluck(:id) + section_training_programs.pluck(:id)).distinct
  end

  # Methods to get training programs by status
  def completed_programs
    all_training_programs.completed
  end

  def ongoing_programs
    all_training_programs.ongoing
  end

  def assignments_for_date(date)
    individual_assignments = Assignment
      .joins(:assignment_participants)
      .where(assignment_participants: { participant_id: id })
      .where("DATE(assignments.start_date) <= ? AND DATE(assignments.end_date) >= ?", date, date)

    section_assignments = Assignment
      .joins(:assignment_sections)
      .where(assignment_sections: { section_id: section_id })
      .where("DATE(assignments.start_date) <= ? AND DATE(assignments.end_date) >= ?", date, date)

    Assignment.where(id: individual_assignments)
      .or(Assignment.where(id: section_assignments))
      .distinct
  end

  private

  def sync_user_associations
    return unless user.present?
    
    # Only update the user's institute_id if it's different
    if user.institute_id != institute_id
      user.update_column(:institute_id, institute_id)
    end
    
    # Get the section_id from the user if it's not set on the participant
    if section_id.nil? && user.section_id.present?
      update_column(:section_id, user.section_id)
    # Update the user's section_id if it's different and section_id is present on the participant
    elsif section_id.present? && user.section_id != section_id
      user.update_column(:section_id, section_id)
    end
  end
end
