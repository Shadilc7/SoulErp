class AddPhoneNumberToTrainers < ActiveRecord::Migration[8.0]
  def change
    add_column :trainers, :phone_number, :string
    add_index :trainers, :phone_number
  end
end
