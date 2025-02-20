class Section < ApplicationRecord
  belongs_to :institute
  has_many :participants, class_name: "User", foreign_key: "section_id", dependent: :nullify
  has_many :training_programs, dependent: :destroy

  validates :name, presence: true
  validates :code, presence: true, uniqueness: { scope: :institute_id }
  validates :capacity, presence: true, numericality: { greater_than: 0 }

  enum :status, {
    active: 0,
    inactive: 1,
    archived: 2
  }, default: :active

  scope :active, -> { where(status: :active) }
end
