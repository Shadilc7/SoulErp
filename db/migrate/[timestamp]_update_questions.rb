class UpdateQuestions < ActiveRecord::Migration[7.0]
  def change
    # Remove old columns if they exist
    remove_column :questions, :options, :json, if_exists: true
    remove_column :questions, :correct_option, :integer, if_exists: true
    remove_column :questions, :correct_answer, :text, if_exists: true

    # Add or modify columns
    change_column :questions, :question_type, :integer, default: 0, null: false
    change_column :questions, :difficulty_level, :integer, default: 1, null: false
  end
end
