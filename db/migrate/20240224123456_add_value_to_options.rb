class AddValueToOptions < ActiveRecord::Migration[7.1]
  def change
    add_column :options, :value, :string
    
    # If you have an existing 'text' column and want to migrate the data
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE options 
          SET value = text 
          WHERE text IS NOT NULL
        SQL
      end
    end
    
    # Optionally remove the old column if it exists
    # remove_column :options, :text
  end
end 