class Option < ApplicationRecord
  belongs_to :question

  validates :text, presence: true
end
