class AddNameFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_index :users, [ :first_name, :last_name ]
  end
end
