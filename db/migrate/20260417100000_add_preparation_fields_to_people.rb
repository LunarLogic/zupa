class AddPreparationFieldsToPeople < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :long_term_provisions, :boolean, default: false, null: false
    add_column :people, :sparkling_water_count, :integer, default: 0, null: false
    add_column :people, :still_water_count, :integer, default: 0, null: false
    add_column :people, :book_preferences, :text
  end
end
