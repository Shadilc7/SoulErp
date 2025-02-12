class CreateTrainingPrograms < ActiveRecord::Migration[8.0]
  def change
    create_table :training_programs do |t|
      t.references :institute, null: false, foreign_key: true
      t.references :trainer, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.datetime :start_date
      t.datetime :end_date
      t.integer :program_type, null: false, default: 0  # 0: individual, 1: section
      t.references :section, foreign_key: true
      t.references :participant, foreign_key: true
      t.integer :status, default: 0  # 0: pending, 1: ongoing, 2: completed, 3: cancelled
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :training_programs, [ :institute_id, :program_type ]
  end
end
