class Participant < ApplicationRecord
  belongs_to :user
  belongs_to :section, optional: true
  belongs_to :institute
  has_one :guardian, dependent: :destroy

  # Update training program associations with dependent: :nullify
  has_many :training_programs, dependent: :nullify
  has_many :section_training_programs, through: :section, source: :training_programs

  # Enhanced phone number validation
  validates :phone_number,
    presence: true,
    uniqueness: { message: "has already been registered" },
    format: {
      with: /\A\d{10}\z/,
      message: "must be exactly 10 digits"
    }
  validates :date_of_birth, presence: true
  validates :institute_id, presence: true
  validates :user, presence: true

  # Add callback to sync institute_id with user
  after_save :sync_institute_with_user

  # Clean phone number before validation
  before_validation :clean_phone_number
  before_save :add_country_code

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

  def clean_phone_number
    # Remove any non-digit characters
    if phone_number.present?
      self.phone_number = phone_number.gsub(/\D/, "")
    end
  end

  def add_country_code
    # Add +91 if not already present
    if phone_number.present? && !phone_number.start_with?("+91")
      self.phone_number = "+91#{phone_number}"
    end
  end

  def sync_institute_with_user
    if institute_id_changed? && user.present?
      user.update_column(:institute_id, institute_id)
    end
  end
end
