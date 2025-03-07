class AddTypeAndEmploymentDetailsToParticipants < ActiveRecord::Migration[8.0]
  def change
    add_column :participants, :participant_type, :string
    add_column :participants, :job_role, :string
    add_column :participants, :qualification, :string
    add_column :participants, :years_of_experience, :integer
    add_column :participants, :guardian_for_participant_id, :integer
  end
end
