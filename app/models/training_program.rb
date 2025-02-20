class TrainingProgram < ApplicationRecord
  belongs_to :institute
  belongs_to :trainer
  belongs_to :section, optional: true
  belongs_to :participant, optional: true

  validates :title, presence: true
  validates :description, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :program_type, presence: true
  validates :trainer_id, presence: true
  validate :valid_program_assignment
  validate :end_date_after_start_date

  enum :program_type, {
    individual: 0,
    section: 1
  }

  enum :status, {
    pending: 0,
    ongoing: 1,
    completed: 2,
    cancelled: 3
  }, default: :pending

  scope :active, -> { where(status: [ :pending, :ongoing ]) }

  private

  def valid_program_assignment
    if individual?
      errors.add(:section_id, "must be blank for individual programs") if section_id.present?
      errors.add(:participant_id, "must be present for individual programs") if participant_id.blank?
    else
      errors.add(:participant_id, "must be blank for section programs") if participant_id.present?
      errors.add(:section_id, "must be present for section programs") if section_id.blank?
    end
  end

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, "must be after the start date")
    end
  end
end
