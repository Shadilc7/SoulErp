class CreateIndividualCertificates < ActiveRecord::Migration[8.0]
  def change
    create_table :individual_certificates do |t|
      t.references :participant, null: false, foreign_key: true
      t.references :assignment, null: false, foreign_key: true
      t.references :certificate_configuration, null: false, foreign_key: true
      t.references :institute, null: false, foreign_key: true
      t.string :filename
      t.datetime :generated_at

      t.timestamps
    end
  end
end
