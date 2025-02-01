class CreateTrainers < ActiveRecord::Migration[8.0]
  def change
    create_table :trainers do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.string :specialization
      t.integer :status
      t.references :institute, null: false, foreign_key: true

      t.timestamps
    end
  end
end
