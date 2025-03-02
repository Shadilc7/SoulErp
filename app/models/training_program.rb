class TrainingProgram < ApplicationRecord
  belongs_to :institute
  belongs_to :trainer
  belongs_to :section, optional: true
  belongs_to :participant, optional: true
  
  # Associations for multiple participants and sections
  has_many :training_program_participants, dependent: :destroy
  has_many :participants, through: :training_program_participants
  
  has_many :training_program_sections, dependent: :destroy
  has_many :sections, through: :training_program_sections
  
  has_one :feedback, class_name: "TrainingProgramFeedback", dependent: :destroy

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

  def progress
    return 100 if completed?
    return 0 if pending? || cancelled? || start_date > Time.current

    total_duration = (end_date - start_date).to_f
    elapsed_time = (Time.current - start_date).to_f
    progress = (elapsed_time / total_duration * 100).round

    [ progress, 100 ].min
  end

  def assignee_name
    if individual?
      if participants.any?
        participants.count > 1 ? "#{participants.count} participants" : participants.first.user.full_name
      else
        participant&.user&.full_name
      end
    else
      if sections.any?
        sections.count > 1 ? "#{sections.count} sections" : sections.first.name
      else
        section&.name
      end
    end
  end

  private

  def valid_program_assignment
    if individual?
      errors.add(:section_id, "must be blank for individual programs") if section_id.present?
      errors.add(:sections, "must be empty for individual programs") if sections.any?
      
      # Check either participant_id or participants
      if participant_id.blank? && participants.empty?
        errors.add(:base, "At least one participant must be selected for individual programs")
      end
    else
      errors.add(:participant_id, "must be blank for section programs") if participant_id.present?
      errors.add(:participants, "must be empty for section programs") if participants.any?
      
      # Check either section_id or sections
      if section_id.blank? && sections.empty?
        errors.add(:base, "At least one section must be selected for section programs")
      end
    end
  end

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, "must be after the start date")
    end
  end
end
