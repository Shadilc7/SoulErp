class AddDetailsToTrainers < ActiveRecord::Migration[8.0]
  def change
    add_column :trainers, :experience_details, :text
    add_column :trainers, :payment_details, :text
    add_column :trainers, :other_details, :text
  end
end
