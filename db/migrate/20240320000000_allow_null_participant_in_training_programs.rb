class AllowNullParticipantInTrainingPrograms < ActiveRecord::Migration[8.0]
  def change
    change_column_null :training_programs, :participant_id, true
  end
end
