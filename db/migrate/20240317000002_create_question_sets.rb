class CreateQuestionSets < ActiveRecord::Migration[8.0]
  def change
    create_table :question_sets do |t|
      t.references :institute, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :total_marks
      t.integer :duration_minutes
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
