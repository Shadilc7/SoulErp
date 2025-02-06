class Institute < ApplicationRecord
  # Associations
  has_many :users
  has_many :sections
  has_many :training_programs
  has_many :trainers
  has_many :participants
  has_many :trainer_profiles
  has_many :participant_profiles

  # Validations
  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :contact_number, presence: true

  # Scopes
  scope :active, -> { where(active: true) }

  def active_trainers_count
    trainers.joins(:user).where(users: { active: true }).count
  end

  def active_participants_count
    participants.joins(:user).where(users: { active: true }).count
  end
end
