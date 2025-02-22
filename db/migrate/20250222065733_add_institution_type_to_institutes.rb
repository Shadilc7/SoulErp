class AddInstitutionTypeToInstitutes < ActiveRecord::Migration[8.0]
  def change
    add_column :institutes, :institution_type, :string
  end
end
