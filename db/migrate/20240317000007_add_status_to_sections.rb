class AddStatusToSections < ActiveRecord::Migration[8.0]
  def change
    add_column :sections, :status, :integer, default: 0, null: false
    remove_column :sections, :active, :boolean if column_exists?(:sections, :active)
  end
end
