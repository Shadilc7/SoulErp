class AddDisplayNameToQuestions < ActiveRecord::Migration[8.0]
  def change
    add_column :questions, :display_name, :string
  end
end
