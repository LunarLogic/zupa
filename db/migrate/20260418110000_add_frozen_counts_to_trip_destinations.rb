class AddFrozenCountsToTripDestinations < ActiveRecord::Migration[7.0]
  def change
    add_column :trip_destinations, :chocolates, :integer, default: 0, null: false
    add_column :trip_destinations, :person_count, :integer, default: 0, null: false
  end
end
