class CreateQuestionSetItems < ActiveRecord::Migration[8.0]
  def change
    create_table :question_set_items do |t|
      t.references :question_set, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.integer :order_number
      t.integer :marks_override

      t.timestamps
    end
  end
end
