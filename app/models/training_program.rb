class TrainingProgram < ApplicationRecord
  belongs_to :institute
  belongs_to :trainer, class_name: "User"

  enum :status, {
    draft: 0,
    active: 1,
    completed: 2,
    cancelled: 3
  }, default: :draft

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end
end
