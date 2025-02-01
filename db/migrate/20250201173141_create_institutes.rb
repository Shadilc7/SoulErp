class CreateInstitutes < ActiveRecord::Migration[8.0]
  def change
    create_table :institutes do |t|
      t.string :name
      t.string :code
      t.text :description
      t.string :address
      t.string :contact_number
      t.string :email
      t.boolean :active

      t.timestamps
    end
  end
end
