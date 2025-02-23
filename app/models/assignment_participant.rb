class AssignmentParticipant < ApplicationRecord
  belongs_to :assignment
  belongs_to :participant
end
