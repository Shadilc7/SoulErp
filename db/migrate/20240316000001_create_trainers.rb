class CreateTrainers < ActiveRecord::Migration[8.0]
  def change
    create_table :trainers do |t|
      t.references :user, null: false, foreign_key: true
      t.references :institute, null: false, foreign_key: true
      t.string :specialization
      t.string :qualification
      t.integer :experience_years
      t.text :bio
      t.string :resume
      t.json :certificates
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
