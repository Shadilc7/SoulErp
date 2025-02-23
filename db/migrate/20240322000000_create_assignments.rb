class CreateAssignments < ActiveRecord::Migration[7.0]
  def change
    create_table :assignments do |t|
      t.references :institute, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false
      t.boolean :active, default: true

      t.timestamps
    end

    create_table :assignment_sections do |t|
      t.references :assignment, null: false, foreign_key: true
      t.references :section, null: false, foreign_key: true
      t.timestamps
    end

    create_table :assignment_participants do |t|
      t.references :assignment, null: false, foreign_key: true
      t.references :participant, null: false, foreign_key: true
      t.timestamps
    end

    create_table :assignment_questions do |t|
      t.references :assignment, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.integer :order_number
      t.timestamps
    end

    create_table :assignment_question_sets do |t|
      t.references :assignment, null: false, foreign_key: true
      t.references :question_set, null: false, foreign_key: true
      t.integer :order_number
      t.timestamps
    end

    create_table :assignment_responses do |t|
      t.references :assignment, null: false, foreign_key: true
      t.references :participant, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.text :answer
      t.jsonb :selected_options
      t.datetime :submitted_at
      t.timestamps
    end
  end
end
