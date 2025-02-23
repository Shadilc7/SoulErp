class AddPhoneNumberToParticipants < ActiveRecord::Migration[8.0]
  def change
    add_column :participants, :phone_number, :string
    add_index :participants, :phone_number
  end
end
