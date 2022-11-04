class RemovePackagesFromTripDestination < ActiveRecord::Migration[7.0]
  def change
    remove_column :trip_destinations, :packages, :integer
  end
end
