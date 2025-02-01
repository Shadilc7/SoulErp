class Institute < ApplicationRecord
  has_many :users
  has_many :training_programs
  has_many :trainers, -> { where(role: :trainer) }, class_name: "User"
  has_many :participants, -> { where(role: :participant) }, class_name: "User"

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :contact_number, presence: true

  scope :active, -> { where(active: true) }
end
