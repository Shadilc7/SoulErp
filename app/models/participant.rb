class Participant < ApplicationRecord
  belongs_to :user
  belongs_to :section, optional: true
  belongs_to :institute
  has_one :guardian

  validates :date_of_birth, presence: true
  validates :education_level, presence: true
  validates :enrollment_date, presence: true

  enum :status, {
    active: 0,
    on_leave: 1,
    graduated: 2,
    dropped: 3
  }, default: :active
end
