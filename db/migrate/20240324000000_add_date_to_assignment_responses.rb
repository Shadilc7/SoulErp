class AddDateToAssignmentResponses < ActiveRecord::Migration[8.0]
  def change
    add_column :assignment_responses, :response_date, :date
    add_index :assignment_responses, :response_date
  end
end
