class CreateParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :participants do |t|
      t.references :user, null: false, foreign_key: true
      t.references :section, null: true, foreign_key: true
      t.references :institute, null: false, foreign_key: true
      t.date :date_of_birth
      t.string :education_level
      t.date :enrollment_date
      t.integer :status, default: 0
      t.text :notes

      t.timestamps
    end
  end
end
