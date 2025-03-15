class AddResponseCountToAssignmentResponseLogs < ActiveRecord::Migration[8.0]
  def change
    add_column :assignment_response_logs, :response_count, :integer
  end
end
