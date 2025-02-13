class AddSectionIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :section, null: true, foreign_key: true
  end
end
