class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable,
         authentication_keys: [ :login ]

  # Skip password validation when password is not being updated
  def password_required?
    return false if persisted? && password.blank? && password_confirmation.blank?
    super
  end

  belongs_to :institute, optional: true
  has_one :trainer, dependent: :destroy
  has_one :participant, dependent: :destroy
  has_one :guardian, dependent: :destroy
  belongs_to :section, optional: true
  has_many :training_programs, foreign_key: :trainer_id

  enum :role, {
    master_admin: 0,
    institute_admin: 1,
    trainer: 2,
    participant: 3,
    guardian: 4
  }, default: :participant

  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }

  attr_accessor :login

  # Scopes
  scope :institute_admin, -> { where(role: :institute_admin) }
  scope :active, -> { where(active: true) }
  scope :trainer, -> { where(role: :trainer) }
  scope :participant, -> { where(role: :participant) }
  scope :guardian, -> { where(role: :guardian) }

  accepts_nested_attributes_for :participant
  accepts_nested_attributes_for :trainer

  def login
    @login || username || email
  end

  # Allow login with username or email
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions.to_h).where([ "lower(username) = :value OR lower(email) = :value",
        { value: login.downcase } ]).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end

  def active_for_authentication?
    super && active?
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def institute_admin?
    role == "institute_admin"
  end

  def trainer?
    role == "trainer"
  end

  def participant?
    role == "participant"
  end
end
