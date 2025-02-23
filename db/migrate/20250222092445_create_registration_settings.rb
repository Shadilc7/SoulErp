class CreateRegistrationSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :registration_settings do |t|
      t.text :enabled_institutes, null: false, default: '--- []'

      t.timestamps
    end
  end
end
