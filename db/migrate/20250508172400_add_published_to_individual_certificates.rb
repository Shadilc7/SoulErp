class AddPublishedToIndividualCertificates < ActiveRecord::Migration[8.0]
  def change
    add_column :individual_certificates, :published, :boolean
  end
end
