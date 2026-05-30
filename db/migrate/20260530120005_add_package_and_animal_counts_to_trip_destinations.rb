class AddPackageAndAnimalCountsToTripDestinations < ActiveRecord::Migration[7.0]
  def change
    add_column :trip_destinations, :package_count, :integer, null: false, default: 0
    add_column :trip_destinations, :animal_count, :integer, null: false, default: 0
  end
end
