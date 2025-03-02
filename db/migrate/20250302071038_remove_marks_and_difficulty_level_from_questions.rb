class RemoveMarksAndDifficultyLevelFromQuestions < ActiveRecord::Migration[8.0]
  def change
    remove_column :questions, :marks, :integer
    remove_column :questions, :difficulty_level, :integer
  end
end
