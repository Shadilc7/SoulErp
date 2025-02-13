class AddStatusToTrainerProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :trainer_profiles, :status, :integer, default: 0, null: false
  end
end
