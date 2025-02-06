class CreateGuardians < ActiveRecord::Migration[8.0]
  def change
    create_table :guardians do |t|
      t.references :user, null: false, foreign_key: true
      t.references :participant, null: false, foreign_key: true
      t.string :relation
      t.string :contact_number
      t.string :occupation
      t.text :address

      t.timestamps
    end
  end
end
