class AddChocolatesAndPersonCountToTripDestinations < ActiveRecord::Migration[7.0]
  def change
    add_column :trip_destinations, :chocolates, :integer, null: false, default: 0
    add_column :trip_destinations, :person_count, :integer, null: false, default: 0
  end
end
