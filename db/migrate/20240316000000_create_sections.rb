class CreateSections < ActiveRecord::Migration[8.0]
  def change
    create_table :sections do |t|
      t.string :name
      t.string :code
      t.references :institute, null: false, foreign_key: true
      t.integer :capacity
      t.text :description
      t.boolean :active, default: true

      t.timestamps
    end
    add_index :sections, [ :code, :institute_id ], unique: true
  end
end
