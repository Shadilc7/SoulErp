class Trainer < ApplicationRecord
  belongs_to :institute
  belongs_to :user, dependent: :destroy
  has_many :training_programs

  validates :institute_id, presence: true
  validates :specialization, presence: true
  validates :qualification, presence: true
  validates :experience_years, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  enum :status, {
    active: 0,
    inactive: 1,
    on_leave: 2
  }, default: :active

  accepts_nested_attributes_for :user

  scope :active, -> { where(status: :active) }

  mount_uploader :resume, ResumeUploader if defined?(CarrierWave)
end
