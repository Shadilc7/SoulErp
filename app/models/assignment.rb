class Assignment < ApplicationRecord
  belongs_to :institute
  belongs_to :section, optional: true

  has_many :assignment_sections, dependent: :destroy
  has_many :sections, through: :assignment_sections

  has_many :assignment_participants, dependent: :destroy
  has_many :participants, through: :assignment_participants

  has_many :assignment_questions, dependent: :destroy
  has_many :questions, through: :assignment_questions

  has_many :assignment_question_sets, dependent: :destroy
  has_many :question_sets, through: :assignment_question_sets

  has_many :assignment_responses, dependent: :destroy

  validates :title, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :assignment_type, presence: true, inclusion: { in: [ "individual", "section" ] }

  validate :end_date_after_start_date
  validate :has_questions_or_question_sets
  validate :has_sections_or_participants

  accepts_nested_attributes_for :assignment_sections, allow_destroy: true
  accepts_nested_attributes_for :assignment_participants, allow_destroy: true
  accepts_nested_attributes_for :assignment_questions, allow_destroy: true
  accepts_nested_attributes_for :assignment_question_sets, allow_destroy: true

  scope :active, -> { where(active: true) }
  scope :current, -> { active.where("start_date <= ? AND end_date >= ?", Time.current, Time.current) }
  scope :upcoming, -> { active.where("start_date > ?", Time.current) }
  scope :past, -> { active.where("end_date < ?", Time.current) }

  def self.permitted_attributes
    [
      :title, :description, :start_date, :end_date,
      :assignment_type, :section_id,
      section_ids: [], participant_ids: [],
      question_ids: [], question_set_ids: []
    ]
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    if end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end

  def has_questions_or_question_sets
    if questions.empty? && question_sets.empty?
      errors.add(:base, "Must have at least one question or question set")
    end
  end

  def has_sections_or_participants
    if assignment_type == "section"
      if section_id.blank? && sections.empty?
        errors.add(:base, "Must select at least one section")
      end
    elsif assignment_type == "individual" && participants.empty?
      errors.add(:base, "Must select at least one participant")
    end
  end
end
