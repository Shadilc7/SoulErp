class Attendance < ApplicationRecord
  belongs_to :training_program
  belongs_to :participant
  belongs_to :marked_by, class_name: 'User'

  validates :date, presence: true
  validates :status, presence: true
  validates :participant_id, 
    uniqueness: { 
      scope: [:training_program_id, :date],
      message: "attendance already marked for this date"
    }

  enum :status, { present: 0, absent: 1, late: 2 }

  scope :by_date, ->(date) { where(date: date) }
  scope :present_statuses, -> { where(status: [:present, :late]) }
  
  # Calculate attendance percentage for a participant in a program
  def self.attendance_percentage(training_program_id, participant_id)
    total = where(training_program_id: training_program_id, participant_id: participant_id).count
    return 0 if total.zero?
    
    present = where(training_program_id: training_program_id, 
                   participant_id: participant_id)
             .present_statuses
             .count
    
    (present.to_f / total * 100).round(2)
  end
end 