class MakeSectionOptionalInParticipantProfiles < ActiveRecord::Migration[8.0]
  def change
    change_column_null :participant_profiles, :section_id, true
  end
end
