class AddAddressDetailsToParticipants < ActiveRecord::Migration[8.0]
  def change
    add_column :participants, :address, :text
    add_column :participants, :pin_code, :string
    add_column :participants, :district, :string
    add_column :participants, :state, :string
  end
end
