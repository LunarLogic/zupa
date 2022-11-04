class AddOrderToTripDestination < ActiveRecord::Migration[7.0]
  def change
    add_column :trip_destinations, :order, :integer
    add_index :trip_destinations, [:trip_group_id, :order], unique: true
  end
end
