class AddAssignmentTypeToAssignments < ActiveRecord::Migration[7.0]
  def change
    add_column :assignments, :assignment_type, :string, default: 'individual'
  end
end
