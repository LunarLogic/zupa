class AddFieldsToTripDestination < ActiveRecord::Migration[7.0]
  def change
    add_column :trip_destinations, :soups, :integer, default: 0
    add_column :trip_destinations, :provisions, :integer, default: 0
    add_column :trip_destinations, :books, :integer, default: 0
    add_column :trip_destinations, :packages, :integer, default: 0
    add_column :trip_destinations, :waters, :integer, default: 0
    add_column :trip_destinations, :additional_info, :text
  end
end
