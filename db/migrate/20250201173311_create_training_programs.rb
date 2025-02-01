class CreateTrainingPrograms < ActiveRecord::Migration[8.0]
  def change
    create_table :training_programs do |t|
      t.string :name
      t.text :description
      t.date :start_date
      t.date :end_date
      t.integer :status
      t.references :institute, null: false, foreign_key: true
      t.references :trainer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
