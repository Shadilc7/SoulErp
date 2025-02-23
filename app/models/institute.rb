class Institute < ApplicationRecord
  # Associations
  has_many :users
  has_many :sections, dependent: :destroy
  has_many :training_programs, dependent: :destroy
  has_many :trainers, dependent: :destroy
  has_many :participants, dependent: :destroy
  has_many :trainer_profiles
  has_many :participant_profiles
  has_many :questions, dependent: :destroy
  has_many :question_sets, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :contact_number, presence: true
  validates :institution_type, presence: true, inclusion: { in: [ "School", "Hospital" ] }

  # Scopes
  scope :active, -> { where(active: true) }

  def active_trainers_count
    trainers.joins(:user).where(users: { active: true }).count
  end

  def active_participants_count
    participants.joins(:user).where(users: { active: true }).count
  end

  # Add a scope to get participants with their users
  def active_participants
    participants.includes(:user).active
  end
end
