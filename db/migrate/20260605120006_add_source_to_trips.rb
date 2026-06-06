class AddSourceToTrips < ActiveRecord::Migration[7.0]
  def change
    add_column :trips, :source, :string, default: "sheet", null: false
    add_index :trips, :source
  end
end
