class Trainer < ApplicationRecord
  belongs_to :user
  belongs_to :institute

  validates :specialization, presence: true
  validates :qualification, presence: true
  validates :experience_years, presence: true, numericality: { greater_than_or_equal_to: 0 }

  enum :status, {
    active: 0,
    on_leave: 1,
    resigned: 2
  }, default: :active

  mount_uploader :resume, ResumeUploader if defined?(CarrierWave)
end
