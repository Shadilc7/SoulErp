class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions do |t|
      t.references :institute, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :question_type, null: false, default: 0
      t.json :options
      t.integer :correct_option
      t.text :correct_answer
      t.integer :marks, default: 1
      t.integer :difficulty_level, default: 0
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
