class AddFieldsToQuestions < ActiveRecord::Migration[7.0]
  def up
    # First, add new columns with null: true
    add_column :questions, :question_type, :integer, if_not_exists: true
    add_column :questions, :difficulty_level, :integer, if_not_exists: true

    # Set default values for existing records
    Question.update_all(question_type: 0, difficulty_level: 1)

    # Now make them non-null with defaults
    change_column_null :questions, :question_type, false
    change_column_null :questions, :difficulty_level, false

    change_column_default :questions, :question_type, 0
    change_column_default :questions, :difficulty_level, 1

    # Remove old columns if they exist
    remove_column :questions, :options, :json if column_exists?(:questions, :options)
    remove_column :questions, :correct_option, :integer if column_exists?(:questions, :correct_option)
    remove_column :questions, :correct_answer, :text if column_exists?(:questions, :correct_answer)
  end

  def down
    # Add back the old columns
    add_column :questions, :options, :json
    add_column :questions, :correct_option, :integer
    add_column :questions, :correct_answer, :text

    # Remove the new columns
    remove_column :questions, :question_type
    remove_column :questions, :difficulty_level
  end
end
