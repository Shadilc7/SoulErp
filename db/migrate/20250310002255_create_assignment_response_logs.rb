class CreateAssignmentResponseLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :assignment_response_logs do |t|
      t.references :institute, null: false, foreign_key: true
      t.references :participant, null: false, foreign_key: true
      t.datetime :response_date
      t.references :assignment, null: false, foreign_key: true
      t.jsonb :assignment_response_ids, default: []

      t.timestamps
    end
  end
end
