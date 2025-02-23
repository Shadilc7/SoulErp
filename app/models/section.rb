class Section < ApplicationRecord
  belongs_to :institute
  has_many :participants, -> { where(role: :participant) }, class_name: "User", foreign_key: "section_id", dependent: :nullify
  has_many :training_programs, dependent: :destroy

  enum :status, { active: 0, inactive: 1 }, default: :active

  validates :name, presence: true
  validates :code, presence: true, uniqueness: { scope: :institute_id }
  validates :capacity, presence: true, numericality: { greater_than: 0 }

  scope :active, -> { where(status: :active) }
end
