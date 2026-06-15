class AddBookPreferencesToLocations < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :book_preferences, :text
  end
end
