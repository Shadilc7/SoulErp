class CreateTrainingProgramFeedbacks < ActiveRecord::Migration[8.0]
  def change
    create_table :training_program_feedbacks do |t|
      t.references :training_program, null: false, foreign_key: true
      t.references :participant, null: false, foreign_key: true
      t.text :content, null: false
      t.integer :rating, null: false
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :training_program_feedbacks, [ :training_program_id, :participant_id ], unique: true, name: 'index_training_program_feedbacks_uniqueness'
  end
end
