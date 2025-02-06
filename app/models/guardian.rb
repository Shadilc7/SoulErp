class Guardian < ApplicationRecord
  belongs_to :user
  belongs_to :participant

  validates :relation, presence: true
  validates :contact_number, presence: true
  validates :occupation, presence: true
end
