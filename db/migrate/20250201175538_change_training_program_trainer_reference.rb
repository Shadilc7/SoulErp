class ChangeTrainingProgramTrainerReference < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :training_programs, :trainers
    add_foreign_key :training_programs, :users, column: :trainer_id
  end
end
