class AddSandwichesToTripDestination < ActiveRecord::Migration[7.0]
  def change
    add_column :trip_destinations, :sandwiches, :integer, default: 0
  end
end
