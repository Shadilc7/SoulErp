class Section < ApplicationRecord
  belongs_to :institute
  has_many :participants, class_name: "User", foreign_key: "section_id", dependent: :nullify

  validates :name, presence: true
  validates :code, presence: true, uniqueness: { scope: :institute_id }
  validates :capacity, presence: true, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }
end
