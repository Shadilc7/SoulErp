class CreateCertificateConfigurations < ActiveRecord::Migration[8.0]
  def change
    create_table :certificate_configurations do |t|
      t.string :name
      t.text :details
      t.integer :duration_period
      t.references :institute, null: false, foreign_key: true
      t.integer :status

      t.timestamps
    end
  end
end
