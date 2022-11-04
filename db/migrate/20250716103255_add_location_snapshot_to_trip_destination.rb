class AddLocationSnapshotToTripDestination < ActiveRecord::Migration[7.0]
  def change
    add_column :trip_destinations, :location_snapshot, :jsonb
  end
end
