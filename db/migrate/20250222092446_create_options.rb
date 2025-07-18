class CreateOptions < ActiveRecord::Migration[7.0]
  def change
    create_table :options do |t|
      t.references :question, null: false, foreign_key: true
      t.text :text, null: false
      t.boolean :correct, default: false

      t.timestamps
    end
  end
end
